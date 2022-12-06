defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  @input """
  mjqjpqmgbljsphdztnvjfqwrcgsmlb
  bvwbjplbgvbhsrlpgdmjqwftvncz
  nppdvjthqldpwncqszvftbrmjlhg
  nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg
  zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw
  """

  test "part1" do
    result = part1(@input)

    assert result == [7, 5, 6, 10, 11]
  end

  test "part2" do
    result = part2(@input)

    assert result == [19, 23, 23, 29, 26]
  end
end
