defmodule RTest do
  use ExUnit.Case
  doctest R

  test "greets the world" do
    assert R.hello() == :world
  end
end
