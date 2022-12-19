defmodule AdventOfCode.Day17Test do
  use ExUnit.Case

  import AdventOfCode.Day17

  @input ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

  test "part1" do
    result = part1(@input)

    assert result == 3068
  end

  @tag :skip
  test "part2" do
    result = part2(@input)

    assert result == 1514285714288
  end
end
