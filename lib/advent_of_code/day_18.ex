defmodule AdventOfCode.Day18 do
  def part1(input) do
    points =
      input
      |> String.split()
      |> Enum.map(fn pt -> String.split(pt, ",") |> Enum.map(&String.to_integer/1) end)

    points |> Enum.reduce(0, fn pt, a -> a + (6 - Enum.count(points, &is_neighbor(&1, pt))) end)
  end

  def part2(_args) do
  end

  defp is_neighbor(pt1, pt2) do
    case {pt1, pt2} do
      {pt, pt} ->
        false

      {[x1, y1, z1], [x2, y2, z2]}
      when (x1 == x2 and y1 == y2 and abs(z1 - z2) == 1) or
             (x1 == x2 and z1 == z2 and abs(y1 - y2) == 1) or
             (y1 == y2 and z1 == z2 and abs(x1 - x2) == 1) ->
        true

      _ ->
        false
    end
  end
end
