defmodule ExBook do
  @moduledoc """
  Documentation for `ExBook`
  A tool to generate livebook documentation for your Elixir Projects.
  """

  @exbook_start_marker "## ExBook"
  @exbook_end_marker "`ExBook_end`"

  @doc """
  Generate livebook docs for an Elixir app.

  Takes an Elixir app and creates the .livemd files for the app modules
  using the documentation.
  Also generates an index.levemd links to the app module notebooks.

  ## Opts
  - :path - define the base path (defaults to "./")
  - :ignore - Modules to ignore
  """
  @spec app_to_exbook(app :: atom(), opts :: [path: String.t(), ignore: list()]) ::
          :ok | {:error, any()}
  def app_to_exbook(app, opts \\ []) do
    base_path = Keyword.get(opts, :path, "./")
    ignored = Keyword.get(opts, :ignore, [])

    app
    |> get_modules(ignored)
    |> create_or_edit_file(base_path, opts)
    |> create_index(app, base_path)
  end

  def module_to_livemd(module, opts \\ []) do
    "Elixir." <> module_name = Atom.to_string(module)

    case Code.fetch_docs(module) do
      {_, _, _, _, %{"en" => _module_doc}, _, _function_docs} = docs ->
        docs_to_livemd(docs, module_name, opts)

      _ ->
        {:error, :no_docs}
    end
  end

  def docs_to_livemd(docs, module_name, opts \\ []) do
    deps = Keyword.get(opts, :deps, nil)

    {_, _, _, _, %{"en" => module_doc}, _, function_docs} = docs

    functions =
      Enum.map(function_docs, fn
        {{:function, fn_name, arity}, _line_number, _usage, %{"en" => doc_string}, _empty_map} ->
          examples =
            doc_string
            |> String.replace(~r/iex\> (.*)(.|\n)+?(?=(iex|$))/, "```elixir\n\\1\n```\n")
            |> String.replace("##", "####")
            |> String.replace(~r/ {2,}/, "")

          "### #{fn_name}/#{arity}\n\n" <> examples

        {{:function, fn_name, arity}, _line_number, _usage, :none, _empty_map} ->
          "### #{fn_name}/#{arity}\n\n"

        _ ->
          ""
      end)
      |> Enum.join("")

    setup = if deps, do: "```elixir\nMix.install(#{inspect(deps)})\n```", else: ""

    # LiveBook is smart enough to percolate the `module_name` to the top of the file
    # However utilizing this in place of our own logic is not wise and should be resolved
    """
    #{@exbook_start_marker}
    # #{module_name}
    #{setup}
    ## Module Doc
    #{module_doc}
    ## Functions
    #{functions}
    #{@exbook_end_marker}
    """
  end

  defp build_app_name(app) do
    app
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end

  defp build_module_links(module_tuples) do
    Enum.map(module_tuples, fn {module, path} ->
      "Elixir." <> module_name = Atom.to_string(module)
      "- [#{module_name}](./#{path})"
    end)
    |> Enum.join("\n")
  end

  defp create_index(module_tuples, app, base_path) do
    app_name = build_app_name(app)
    module_links = build_module_links(module_tuples)

    Path.join(base_path, "index.livemd")
    |> File.write!("""
    # #{app_name}

    ## Modules
    #{module_links}
    """)
  end

  defp create_or_edit_file(module_tuples, base_path, opts) do
    Enum.each(module_tuples, fn {module, path} ->
      path = Path.join(base_path, path)
      File.mkdir_p!(Path.dirname(path))

      case File.exists?(path) do
        false ->
          File.write(path, module_to_livemd(module, opts))

        true ->
          docs = module_to_livemd(module, opts)
          stream = File.stream!(path)
          exbook_start = Enum.find_index(stream, &(&1 == "#{@exbook_start_marker}\n"))
          exbook_end = Enum.find_index(stream, &(&1 == "#{@exbook_end_marker}\n"))

          {:ok, updated_docs} =
            case {exbook_start, exbook_end} do
              {nil, nil} ->
                # a decision has to be made here, putting it at the end may not be ideal
                # however it's the least disruptive decision
                {:ok, Enum.slice(stream, 0..-1) ++ [docs]}

              # Failing hard in the error cases is acceptable for now,
              # However a graceful return with more meaningful info is preferred
              {_ex_doc_start, nil} ->
                {:error, :corrupted_file}

              {nil, _ex_doc_end} ->
                {:error, :corrupted_file}

              {exbook_start, exbook_end} ->
                exbook_start = exbook_start - 1
                exbook_end = exbook_end + 1

                preamble = Enum.slice(stream, 0..exbook_start)

                exbook_and_postscript =
                  Enum.slice(stream, exbook_end..-1)
                  |> clean_file(docs)

                {:ok, preamble ++ exbook_and_postscript}
            end

          Stream.into(updated_docs, stream) |> Stream.run()
      end
    end)

    module_tuples
  end

  # TODO refactor:
  # Not in love with this, there's a better way I'm sure but can't think of one right now.
  defp clean_file(stream, docs) do
    open = Enum.find_index(stream, &(&1 == "#{@exbook_start_marker}\n"))
    close = Enum.find_index(stream, &(&1 == "#{@exbook_end_marker}\n"))

    case {open, close} do
      {nil, nil} ->
        List.flatten([docs] ++ stream)

      {_open, nil} ->
        {:error, :corrupted_file}

      {nil, _close} ->
        {:error, :corrupted_file}

      {open, close} ->
        open = open - 1
        close = close + 1
        (Enum.slice(stream, 0..open) ++ Enum.slice(stream, close..-1)) |> clean_file(docs)
    end
  end

  defp get_modules(app, ignored) do
    {:ok, modules} = :application.get_key(app, :modules)

    Enum.map(modules, fn module ->
      [_elixir | module_names] = Atom.to_string(module) |> String.split(".")

      module_name = Enum.join(module_names, "/")
      path = module_name <> ".livemd"

      {module, path}
    end)
    |> Enum.reject(fn {module, _path} -> module in ignored end)
  end
end
