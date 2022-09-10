defmodule ExBook do
  @moduledoc """
  Documentation for `ExBook`
  A tool to generate livebook documentation for your Elixir Projects.
  """

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

    {:ok, modules} = :application.get_key(app, :modules)

    module_tuples =
      Enum.map(modules, fn module ->
        [_elixir | module_names] = Atom.to_string(module) |> String.split(".")
        module_name = Enum.join(module_names, "/")
        path = module_name <> ".livemd"
        {module, path}
      end)
      |> Enum.reject(fn {module, _path} -> module in ignored end)

    Enum.each(module_tuples, fn {module, path} ->
      path = Path.join(base_path, path)
      File.mkdir_p!(Path.dirname(path))
      File.write(path, module_to_livemd(module, opts))
    end)

    app_name =
      Atom.to_string(app) |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join("")

    module_links =
      Enum.map(module_tuples, fn {module, path} ->
        "Elixir." <> module_name = Atom.to_string(module)
        "- [#{module_name}](./#{path})"
      end)
      |> Enum.join("\n")

    File.write(base_path <> "index.livemd", """
    # #{app_name}

    ## Modules
    #{module_links}
    """)
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
            |> String.replace(~r/iex\> (.*)(.|\n)+?(?=(iex|$))/, "```elixir\n\\1\n```")
            |> String.replace("##", "####")
            |> String.replace(~r/ {2,}/, "")

          "### #{fn_name}/#{arity}\n\n" <> examples

        {{:function, fn_name, arity}, _line_number, _usage, :none, _empty_map} ->
          "### #{fn_name}/#{arity}\n\n"
      end)
      |> Enum.join("")

    setup = if deps, do: "```elixir\nMix.install(#{inspect(deps)})\n```", else: ""

    """
    # #{module_name}
    #{setup}
    ## Module Doc
    #{module_doc}
    ## Functions
    #{functions}
    """
  end
end
