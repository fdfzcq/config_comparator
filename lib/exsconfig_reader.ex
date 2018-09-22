defmodule ConfigComparator.ExsconfigReader do
  def read(path) do
    read(path, File.exists?(path))
  end

  defp read(_path, false) do
    {:error, "File not found"}
  end

  defp read(path, true) do
    Mix.env(:prod)
    elem(Mix.Config.eval!(path), 0)
  end
end
