defmodule AdventOfCode.Day18 do
  def part1(input) do
    blocks =
      input
      |> parse()
      |> MapSet.new()

    blocks
    |> Enum.map(&(neighbors(&1) |> Enum.count(fn n -> n not in blocks end)))
    |> Enum.sum()
  end

  def part2(input) do
    blocks =
      input
      |> parse()
      |> MapSet.new()

    max_extent =
      Enum.reduce(blocks, 0, fn {x, y, z}, a -> x |> max(y) |> max(z) |> max(a) end) + 1

    flood(blocks, max_extent, [{-1, -1, -1}], MapSet.new())
    |> Enum.map(&(neighbors(&1) |> Enum.count(fn n -> n in blocks end)))
    |> Enum.sum()
  end

  defp flood(_blocks, _max_extent, [], closed), do: closed

  defp flood(blocks, max_extent, [head | tail], closed) do
    to_visit =
      head
      |> neighbors()
      |> MapSet.difference(blocks)
      |> MapSet.difference(closed)
      |> Enum.filter(&in_bounds(&1, max_extent))

    flood(blocks, max_extent, to_visit ++ tail, MapSet.put(closed, head))
  end

  defp in_bounds(block, max_extent) do
    block |> Tuple.to_list() |> Enum.all?(&(&1 >= -1 and &1 <= max_extent))
  end

  defp parse(input) do
    input
    |> String.split()
    |> Enum.map(fn pt ->
      String.split(pt, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  defp neighbors({x, y, z}),
    do:
      MapSet.new(
        [-1, 1]
        |> Enum.map(&[{x + &1, y, z}, {x, y + &1, z}, {x, y, z + &1}])
        |> List.flatten()
      )
end
