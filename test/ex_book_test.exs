defmodule ExBookTest do
  use ExUnit.Case
  doctest ExBook

  @app_path "./test_notebooks/"

  test "app_to_exbook/1 generate project livebooks" do
    File.rm_rf("test_notebooks")

    ExBook.app_to_exbook(:ex_book,
      path: @app_path,
      ignore: [ExBook, Mix.Tasks.Notebooks],
      deps: [{:kino, "~> 0.6.2"}, {:ex_doc, path: "./"}]
    )
    setup = "```elixir\nMix.install([kino: \"~> 0.6.2\", ex_doc: [path: \"./\"]])\n```"

    assert File.read!(@app_path <> "ExampleModule.livemd") == example_doc("ExampleModule", setup)

    assert File.read!(@app_path <> "ExampleModule/SubExample1.livemd") ==
             example_doc("ExampleModule.SubExample1", setup)

    assert File.read!(@app_path <> "ExampleModule/SubExample2.livemd") ==
             example_doc("ExampleModule.SubExample2", setup)

    assert File.read!(@app_path <> "ExampleModule/SubExample3.livemd") ==
             example_doc("ExampleModule.SubExample3", setup)

    refute File.exists?(@app_path <> "ExBook.livemd")

    assert File.read!(@app_path <> "index.livemd") == """
           # ExBook

           ## Modules
           - [ExampleModule](./ExampleModule.livemd)
           - [ExampleModule.SubExample1](./ExampleModule/SubExample1.livemd)
           - [ExampleModule.SubExample2](./ExampleModule/SubExample2.livemd)
           - [ExampleModule.SubExample3](./ExampleModule/SubExample3.livemd)
           """

    # File.rm_rf("test_notebooks")
  end

  test "app_to_exbook/1 only changes the appropriate tags in the livemd" do
    #TODO
    File.rm_rf("test_notebooks")

    ExBook.app_to_exbook(:ex_book,
      path: @app_path,
      ignore: [ExBook, Mix.Tasks.Notebooks],
      deps: [{:kino, "~> 0.6.2"}, {:ex_doc, path: "./"}]
    )
    setup = "```elixir\nMix.install([kino: \"~> 0.6.2\", ex_doc: [path: \"./\"]])\n```"

    assert File.read!(@app_path <> "ExampleModule.livemd") == example_doc("ExampleModule", setup)

    assert File.read!(@app_path <> "ExampleModule/SubExample1.livemd") ==
             example_doc("ExampleModule.SubExample1", setup)

    assert File.read!(@app_path <> "ExampleModule/SubExample2.livemd") ==
             example_doc("ExampleModule.SubExample2", setup)

    assert File.read!(@app_path <> "ExampleModule/SubExample3.livemd") ==
             example_doc("ExampleModule.SubExample3", setup)

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

  defp example_doc(module_name \\ "ExampleModule", setup \\ "") do
    """
    # #{module_name}
    #{setup}
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
