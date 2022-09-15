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


### TODO
- modules without documentation, how do we want to handle them? currently we have them in the index, but don't generate a file for them
- display macros?
- display private functions?
- Set notebook title if none exists
- Figure out best way to create sections so that larger docs are more navigable
- What to do when there's no docs to publish to the file, currently not created
