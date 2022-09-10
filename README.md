# ExBook

ExBook is a tool to generate livebook notebook documentation for your Elixir projects.

## Installation

add ExBook to your dependencies in `mix.exs`

``` elixir
defp deps do
  [
    {:ExBook, git: "https://github.com/BrooklinJazz/exbook.git"}
  ]
```

Then run `mix deps.get` to install it.

## Usage 

### Specific Module

``` elixir
Exbook.module_to_livemd(YourModule)
```
