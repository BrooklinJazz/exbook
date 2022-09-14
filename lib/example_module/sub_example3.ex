defmodule ExampleModule.SubExample3 do
  @moduledoc """
  Documentation for `ExampleModule`
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

  @doc """
  Block to test handling multiple doctests

    ## Examples

      iex> ExampleModule.parrot("goose")
      "goose"

      iex> ExampleModule.parrot("parrot")
      "I'm Cicil"
  """
  def parrot(speak) do
    case speak do
      "parrot" -> "I'm Cicil"
      speak -> speak
    end
  end
end
