defmodule Mix.Tasks.Notebooks do
  use Mix.Task

  def run(_args) do
    opts =
      case File.read(".exbooks.exs") do
        {:ok, file} -> :erlang.binary_to_term(file)
        _ -> [path: "./notebooks", ignore: []]
      end

    IO.inspect(File.ls!(), label: "FILES")
    IO.inspect(opts, label: "OPTS")

    app = Mix.Project.config()[:app]
    IO.inspect(app, label: "APP")
    # ExBook.app_to_exbook(app, opts)
  end
end
