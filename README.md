# ConfigComparator

Used to compare erlang sys.config configuration file with the elixir .exs configuration file.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `config_comparator` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:config_comparator, "~> 0.1.0"}]
    end
    ```

  2. Ensure `config_comparator` is started before your application:

    ```elixir
    def application do
      [applications: [:config_comparator]]
    end
    ```
## Commands

### Example usage:
```elixir
ConfigComparator.Comparator.compare({{path_to_sysconfig}}, {{path_to_elixir_config}})
```
### Example output:
```bash
Difference found: {{:foo, foo}, :foo}
In exs config: [%{country: "England"}]
But in sys.config: [%{country: "England"}, %{country: "Germany"}]

Difference found: {{:bar, bar}, :bar}
In exs config: 90
But in sys.config: 100
```
```bash
No difference found!
```

## Configuration

```elixir
# config/config.exs
e.g.
  config :config_comparator, ignored_keys:
                          [{{:a, :b}, :c},
                           {{:foo, :bar}, :hello_world}]
```


