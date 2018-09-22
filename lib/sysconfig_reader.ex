defmodule ConfigComparator.SysconfigReader do
  use GenServer

  def start_link(path) do
    GenServer.start_link(__MODULE__, [path], name: __MODULE__)
  end

  def init([path]) do
    read(path)
  end

  def read(path) do
    read(path, File.exists?(path))
  end

  def handle_call({:get, {key1, key2}}, _from, state = {{:sysconfig, config}, _}) do
    value =
      config
      |> Enum.into(%{})
      |> Map.get(key1)
      |> Enum.into(%{})
      |> Map.get(key2)

    {:reply, {:ok, value}, state}
  end

  def handle_call({:get, key}, _from, state = {{:sysconfig, config}, _}) do
    value =
      config
      |> Enum.into(%{})
      |> Map.get(key)

    {:reply, {:ok, value}, state}
  end

  def handle_call({:diff, exs_config}, _fromt, _state = {{:sysconfig, config}, _}) do
    diffs = find_diffs(exs_config, config, [{:missing, []}, {:diff, []}], "N/A")
    puts(diffs)
    {:reply, :ok, {{:sysconfig, config}, {:diff, diffs}}}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def get_value({key1, key2}) do
    GenServer.call(__MODULE__, {:get, key1, key2})
  end

  def get_value(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def get_value(key, config) do
    config
    |> Enum.into(%{})
    |> Map.get(key)
  end

  def diff(exs_config) do
    GenServer.call(__MODULE__, {:diff, exs_config})
  end

  defp read(_path, false) do
    {:error, "File not found"}
  end

  defp read(path, true) do
    {:ok, config} = :file.read_file(path)
    sysconfig_str = :lists.append(:string.tokens(:erlang.binary_to_list(config), '\n '))
    {:ok, tokens, _} = :erl_scan.string(sysconfig_str)
    {:ok, result} = :erl_parse.parse_term(tokens)
    {:ok, {{:sysconfig, result}, {:diff, []}}}
  end

  defp compare(nil, _) do
    reason = "Error, no value in exs config"
    {:ignore, reason}
  end

  defp compare(_, nil) do
    reason = "Mismatch found, no value in sys.config"
    {:mismatch, reason}
  end

  defp compare(value, value) do
    {:match, value}
  end

  defp compare(value_exs, value_sys) do
    {:mismatch, value_exs, value_sys}
  end

  defp find_diffs(exs_config, config, a, k) do
    exs_config
    |> Enum.reduce(
      a,
      fn _x = {key, value}, acc = [{_, missing}, {_, diff}] ->
        case compare(value, get_value(key, config)) do
          {:ignore, _res} ->
            acc

          {:mismatch, _res} ->
            puts(:missing, keys(k, key))
            [{:missing, [keys(k, key) | missing]}, {:diff, diff}]

          {:match, _value} ->
            acc

          {:mismatch, val1 = [{_, _} | _tail], val2} ->
            [{_, missing2}, {_, diff2}] = find_diffs(val1, val2, acc, keys(k, key))
            [{:missing, :lists.append(missing, missing2)}, {:diff, :lists.append(diff, diff2)}]

          {:mismatch, val1, val2} ->
            case filter(keys(k, key)) do
              {:filter, _} ->
                acc

              valid_key ->
                puts(:diff, valid_key, val1, val2)
                [{:missing, missing}, {:diff, [{valid_key, {val1, val2}} | diff]}]
            end
        end
      end
    )
  end

  defp filter(key) do
    :config_comparator
    |> Application.get_env(:ignored_keys)
    |> Enum.any?(fn k -> k == key end)
    |> filter(key)
  end

  defp filter(true, key) do
    {:filter, key}
  end

  defp filter(_, key) do
    key
  end

  defp keys(k, key) do
    case k do
      "N/A" -> key
      k -> {k, key}
    end
  end

  defp puts([{:missing, []}, {:diff, []}]) do
    [:green, "No difference found!"]
    |> Bunt.puts()
  end

  defp puts(_) do
  end

  defp puts(:missing, key) do
    ["sys.config Missing: ", :yellow, "#{inspect(key)}\n"]
    |> Bunt.puts()
  end

  defp puts(:diff, key, val1, val2) do
    "Difference found: #{inspect(key)}"
    |> IO.puts()

    ["In exs config:", :green, " #{inspect(val1)}"]
    |> Bunt.puts()

    ["But in sys.config:", :red, " #{inspect(val2)}\n"]
    |> Bunt.puts()
  end
end
