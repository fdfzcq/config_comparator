defmodule ConfigComparator.ComparatorTest do
  use ExUnit.Case
  alias ConfigComparator.Comparator

  test "compare two configs" do
    exs_config_path = "test/config/test.exs"
    sys_config_path = "test/config/test.sys.config"
    Comparator.compare(sys_config_path,exs_config_path)
  end

  test "same configs" do
    exs_config_path = "test/config/test.exs"
    sys_config_path = "test/config/test_same.sys.config"
    Comparator.compare(sys_config_path,exs_config_path)
  end
end
