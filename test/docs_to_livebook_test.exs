defmodule DocsToLivebookTest do
  use ExUnit.Case
  doctest DocsToLivebook
  import IEx.Helpers

  test "greets the world" do
    assert DocsToLivebook.hello() == :world
  end

  defmodule ExampleModule do
    @moduledoc """
    Example
    """

    @doc """
    Example Function

      ## Examples

        iex> ExampleModule.hello()
        :hello
    """
    def hello() do
      :hello
    end
  end

  # test "module_to_livemd/1" do

  #   assert DocsToLivebook.module_to_livemd(ExampleModule) == """
  #          # ExampleModule

  #          ## Module Doc
  #          Example

  #          ## Functions

  #          ### hello/0

  #          Example Function

  #          ```elixir
  #          ExampleModule.hello()
  #          ```
  #          """
  # end

  test "all_modules_to_livemd"
  test "write livemd to file"

  test "doc_to_livebook/1" do
    docs =
      {:docs_v1, 2, :elixir, "text/markdown", %{"en" => "Documentation for `DocsToLivebook`.\n"},
       %{},
       [
         {{:function, :hello, 0}, 6, ["hello()"],
          %{
            "en" =>
              "Hello world.\n\n## Examples\n\n    iex> DocsToLivebook.hello()\n    :world\n\n"
          }, %{}}
       ]}

    expected_output = """
    # ModuleName

    ## Module Doc
    Documentation for `DocsToLivebook`.

    ## Functions
    ### hello/0

    Hello world.

    ```elixir
    DocsToLivebook.hello()
    ```
    """

    assert DocsToLivebook.docs_to_livemd(docs) == expected_output
  end
end
