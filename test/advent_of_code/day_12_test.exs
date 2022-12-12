defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  @input """
  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
  """

  test "part1" do
    result = part1(@input)

    assert result == 31
  end

  test "part2" do
    result = part2(@input)

    assert result == 29
  end
end
