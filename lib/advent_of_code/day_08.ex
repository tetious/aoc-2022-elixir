defmodule TreeSizeMap do
  defstruct rows: [], cols: [], width: 0, height: 0

  def new(input) do
    parsed =
      input
      |> String.trim()
      |> String.split("\n")

    rows =
      parsed
      |> Enum.map(&get_row/1)
      |> List.to_tuple()

    height = tuple_size(rows)

    cols =
      Range.new(0, height - 1)
      |> Enum.map(&get_col(parsed, &1))
      |> List.to_tuple()

    %TreeSizeMap{rows: rows, cols: cols, width: tuple_size(cols), height: height}
  end

  def edge_height_cast(map),
    do: for(pos <- 0..(map.width * map.height - 1), do: edge_height_cast(map, pos))

  defp edge_height_cast(map, pos)
       when rem(pos, map.width) == map.width - 1 or div(pos, map.width) == map.width - 1 or
              rem(pos, map.height) == map.width - 1 or div(pos, map.height) == map.width - 1 or
              rem(pos, map.height) == 0 or div(pos, map.height) == 0 or
              rem(pos, map.width) == 0 or div(pos, map.width) == 0,
       do: {true, 0}

  defp edge_height_cast(map, pos) do
    x = rem(pos, map.width)
    y = div(pos, map.height)
    col = elem(map.cols, x)
    row = elem(map.rows, y)

    [size | right] = Enum.slice(row, x, map.width - x)

    [
      right,
      Enum.slice(row, 0, x) |> Enum.reverse(),
      Enum.slice(col, y + 1, map.height - y),
      Enum.slice(col, 0, y) |> Enum.reverse()
    ]
    |> Enum.map(&tree_edge_cast(&1, size, 0))
    |> scenic_score()
  end

  defp scenic_score(list),
    do: Enum.reduce(list, fn {v, s}, {av, as} -> {av || v, s * as} end)

  defp tree_edge_cast([next | _rest], size, steps) when next >= size,
    do: {false, steps + 1}

  defp tree_edge_cast([], _size, steps), do: {true, steps}

  defp tree_edge_cast([next | rest], size, steps) when next < size,
    do: tree_edge_cast(rest, size, steps + 1)

  defp get_row(input),
    do: String.split(input, "") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.to_integer/1)

  defp get_col(rows, col),
    do: for(y <- rows, do: String.slice(y, col, 1) |> String.to_integer())
end

defmodule AdventOfCode.Day08 do
  def part1(input) do
    input
    |> TreeSizeMap.new()
    |> TreeSizeMap.edge_height_cast()
    |> Enum.filter(&elem(&1, 0))
    |> Enum.count()
  end

  def part2(input) do
    input
    |> TreeSizeMap.new()
    |> TreeSizeMap.edge_height_cast()
    |> Enum.map(&elem(&1, 1))
    |> Enum.max()
  end
end
