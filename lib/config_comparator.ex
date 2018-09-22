defmodule ConfigComparator.Comparator do
  use GenServer

  def process(args) do
    {sysconfig_path, exsconfig_path} = to_paths(args)
    compare(sysconfig_path, exsconfig_path)
  end

  def compare(sysconfig_path, exsconfig_path) do
    case ConfigComparator.SysconfigReader.start_link(sysconfig_path) do
      {:error, {:already_started, pid}} ->
        GenServer.stop(pid)
        compare(sysconfig_path, exsconfig_path)

      _ ->
        exsconfig_path
        |> ConfigComparator.ExsconfigReader.read()
        |> ConfigComparator.SysconfigReader.diff()
    end
  end

  defp to_paths([h | [t]]) do
    case is_exs(h) do
      true -> {t, h}
      false -> {h, t}
    end
  end

  defp to_paths(_), do: raise("Invalid arguments")

  defp is_exs(path) when is_binary(path), do: is_exs(String.split("."))

  defp is_exs(["exs"]), do: true
  defp is_exs([h | t]), do: is_exs(t)
  defp is_exs(_), do: false
end
