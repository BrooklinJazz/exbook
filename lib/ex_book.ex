defmodule ExBook do
  @moduledoc """
  Documentation for `ExBook`.
  """

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
      File.mkdir_p!(Path.dirname(base_path <> path))
      File.write(base_path <> path, module_to_livemd(module, opts))
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

    Code.fetch_docs(ExampleModule)
    |> docs_to_livemd(module_name, opts)
  end

  def docs_to_livemd(docs, module_name, opts \\ []) do
    deps = Keyword.get(opts, :deps, nil)
    {_, _, _, _, %{"en" => module_doc}, _, function_docs} = docs

    functions =
      Enum.map(function_docs, fn doc ->
        {{:function, fn_name, arity}, line_number, _usage, %{"en" => doc_string}, _empty_map} =
          doc

        examples =
          doc_string
          |> String.replace(~r/iex\> (.*)(.|\n)+?(?=(iex|$))/, "```elixir\n\\1\n```")
          |> String.replace("##", "####")
          |> String.replace(~r/ {2,}/, "")

        "### #{fn_name}/#{arity}\n\n" <> examples
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
