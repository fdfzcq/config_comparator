defmodule ConfigComparator.Comparator do
  use GenServer

  def compare(sysconfig_path, exsconfig_path) do
    case ConfigComparator.SysconfigReader.start_link(sysconfig_path) do
      {:error, {:already_started, pid}} ->
                              GenServer.stop(pid)
                              compare(sysconfig_path, exsconfig_path)
      _ -> exsconfig_path
          |> ConfigComparator.ExsconfigReader.read
          |> ConfigComparator.SysconfigReader.diff
    end
  end

end
