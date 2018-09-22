defmodule Mix.Tasks.Config do
  defmodule Compare do
    use Mix.Task

    def run(args) do
      try do
        ConfigComparator.Comparator.process(args)
      catch
        err -> raise err
      end
    end
  end
end
