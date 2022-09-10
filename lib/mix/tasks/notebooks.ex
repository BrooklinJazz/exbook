defmodule Mix.Tasks.Notebooks do
  use Mix.Task

  def run(_args) do
    opts =
      case File.read(".exbooks.exs") do
        {:ok, file} -> :erlang.binary_to_term(file)
        _ -> [path: "./notebooks", ignore: []]
      end

    Mix.Task.run("app.start")


    app = Mix.Project.config()[:app]
    ExBook.app_to_exbook(app, opts)
  end
end
