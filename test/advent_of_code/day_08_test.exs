defmodule AdventOfCode.Day08Test do
  use ExUnit.Case

  import AdventOfCode.Day08

  @input """
  30373
  25512
  65332
  33549
  35390
  """

  test "part1" do
    result = part1(@input)

    assert result == 21
  end

  test "part2" do
    result = part2(@input)

    assert result == 8
  end
end
