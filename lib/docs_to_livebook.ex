defmodule DocsToLivebook do
  @moduledoc """
  Documentation for `DocsToLivebook`.
  """

  def docs_to_livemd(docs) do
    {_, _, _, _, %{"en" => module_doc}, _, function_docs} = docs

    Enum.map(function_docs, fn doc ->
      {{:function, fn_name, arity}, line_number, _usage, %{"en" => doc_string}, _empty_map} = doc

      Regex.replace(~r/iex\> (.*)(.|\n)+?(?=(iex|$))/, doc_string, "```elixir\n\\1\n```")
      #   # fn to_replace, group ->
      #   #   """
      #   #   ```elixir
      #   #   #{group}
      #   #   ```
      #   #   """
      |> IO.inspect()
    end)

    """
    # ModuleName

    ## Module Doc
    #{module_doc}

    ## Functions

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
