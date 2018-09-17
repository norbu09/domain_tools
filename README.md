# DomainTools

Domain tools that I need constantly unified into one module. I have added so far:
- domain splitting based on the public suffix list
- IDN conversion

These can easily be used just by validating a domain name like this:

```elixir
iex> DomainTools.validate("zen.xn--unup4y")
{:ok, %{domain: "zen.xn--unup4y", host: "zen", tld: "xn--unup4y", unicode: "zen.游戏"}}
iex> DomainTools.validate("zen.游戏")
{:ok, %{domain: "zen.xn--unup4y", host: "zen", tld: "xn--unup4y", unicode: "zen.游戏"}}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `domain_tools` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:domain_tools, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/domain_tools](https://hexdocs.pm/domain_tools).

