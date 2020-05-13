defmodule VintageNet.ActivityMonitor.ClassifierTest do
  use ExUnit.Case

  alias VintageNet.ActivityMonitor.Classifier

  doctest Classifier

  test "classifier" do
    addresses = []

    assert Classifier.classify("eth0") == :ethernet
  end
end
