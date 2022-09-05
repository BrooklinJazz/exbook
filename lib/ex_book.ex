defmodule ExBook do
  @moduledoc """
  Documentation for `ExBook`.
  """

  def app_to_exbook(app, opts \\ []) do
    base_path = Keyword.get(opts, :path, "./")
    {:ok, modules} = :application.get_key(app, :modules)

    Enum.map(modules, fn module ->
      [_elixir | module_names] = Atom.to_string(module) |> String.split(".")
      module_name = Enum.join(module_names, "/")
      path = base_path <> module_name <> ".livemd"
      File.mkdir_p!(Path.dirname(path))
      File.write(path, module_to_livemd(module))
    end)
  end

  def module_to_livemd(module) do
    "Elixir." <> module_name = Atom.to_string(module)

    Code.fetch_docs(ExampleModule)
    |> docs_to_livemd(module_name)
  end

  def docs_to_livemd(docs, module_name) do
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

    """
    # #{module_name}

    ## Module Doc
    #{module_doc}
    ## Functions
    #{functions}
    """
  end

  def module_to_livemd(module) do
    "Elixir." <> module_name = Atom.to_string(module)

    {_, _, _, module_doc, _, _, function_doc_list} = Code.fetch_docs(module) |> IO.inspect()

    IO.inspect(module_doc)

    """
    # #{module_name}

    ## Module Doc


    """
  end
end
