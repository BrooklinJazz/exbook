defmodule ExBookTest do
  use ExUnit.Case
  doctest ExBook
  import IEx.Helpers

  @app_path "./test_notebooks/"

  test "app_to_exbook/1 generate project livebooks" do
    # example_module.livemd
    # example_module/sub_example1.livemd
    # example_module/sub_example2.livemd
    # index.livemd

    File.rm_rf("test_notebooks")

    ExBook.app_to_exbook(:ex_book, path: @app_path, ignore: [ExBook])

    assert File.read!(@app_path <> "ExampleModule.livemd") == example_doc()

    assert File.read!(@app_path <> "ExampleModule/SubExample1.livemd") ==
             example_doc("ExampleModule.SubExample1")

    assert File.read!(@app_path <> "ExampleModule/SubExample2.livemd") ==
             example_doc("ExampleModule.SubExample2")

    assert File.read!(@app_path <> "ExampleModule/SubExample3.livemd") ==
             example_doc("ExampleModule.SubExample3")

    refute File.exists?(@app_path <> "ExBook.livemd")

    assert File.read!(@app_path <> "index.livemd") == """
           # ExBook

           ## Modules
           - [ExampleModule](./ExampleModule.livemd)
           - [ExampleModule.SubExample1](./ExampleModule/SubExample1.livemd)
           - [ExampleModule.SubExample2](./ExampleModule/SubExample2.livemd)
           - [ExampleModule.SubExample3](./ExampleModule/SubExample3.livemd)
           """

    File.rm_rf("test_notebooks")
  end

  test "module to livemd/1" do
    assert ExBook.module_to_livemd(ExampleModule) == example_doc()
  end

  test "doc_to_livemd/1" do
    docs = Code.fetch_docs(ExampleModule)

    assert ExBook.docs_to_livemd(docs, "ExampleModule") == example_doc()
  end

  defp example_doc(module_name \\ "ExampleModule") do
    """
    # #{module_name}

    ## Module Doc
    Documentation for `ExampleModule`

    ## Functions
    ### hello/0

    Example Function

    #### Examples

    ```elixir
    ExampleModule.hello()
    ```

    """
  end
end
