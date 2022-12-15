defmodule Sensor do
  def range_at([sx, sy | _] = point, y) do
    range = distance(point) - abs(sy - y)
    if range > 0, do: (sx - range)..(sx + range), else: nil
  end

  def combine(range, list), do: do_combine(list, range, list)

  defp do_combine([s1..e1 | tail], s2..e2, _) when e1 == s2 or s2 - e1 <= 1,
    do: [s1..max(e1, e2) | tail]

  defp do_combine([_ | tail], range, list), do: do_combine(tail, range, list)
  defp do_combine([], range, list), do: [range | list]

  defp distance([sx, sy, bx, by]), do: abs(sx - bx) + abs(sy - by)
end

defmodule AdventOfCode.Day15 do
  @sensor_regex ~r/^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/m

  def part1(input, y \\ 2_000_000) do
    x_min..x_max =
      parse(input)
      |> Enum.reduce([], &(Sensor.range_at(&1, y) |> append(&2)))
      |> Enum.reduce(fn min..max, a_min..a_max -> min(min, a_min)..max(max, a_max) end)

    abs(x_min) + abs(x_max)
  end

  def part2(input, y \\ 4_000_000) do
    sensors = parse(input)

    {y, [_..e1, _]} =
      for y <- 0..y do
        {y,
         sensors
         |> Enum.reduce([], &(Sensor.range_at(&1, y) |> append(&2)))
         |> Enum.sort()
         |> Enum.reduce([], &Sensor.combine/2)
         |> Enum.sort()}
      end
      |> Enum.filter(fn {_y, ranges} -> length(ranges) > 1 end)
      |> hd()

    (e1 + 1) * 4_000_000 + y
  end

  defp parse(input) do
    Regex.scan(@sensor_regex, input, capture: :all_but_first)
    |> Enum.map(&Enum.map(&1, fn n -> String.to_integer(n) end))
  end

  defp append(nil, list), do: list
  defp append(range, list), do: [range | list]
end
