defmodule MapNode do
  @enforce_keys [:loc, :height]
  defstruct [:loc, :height, parent: nil, f: 0, g: 0]
end

defmodule HeightMap do
  def new(input) do
    input
    |> String.split()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, ay ->
      row
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(ay, fn {height, x}, ax ->
        case height do
          ?S -> %{:start => {x, y}, {x, y} => %MapNode{loc: {x, y}, height: ?a}}
          ?E -> %{:dest => {x, y}, {x, y} => %MapNode{loc: {x, y}, height: ?z}}
          _ -> %{{x, y} => %MapNode{loc: {x, y}, height: height}}
        end
        |> Map.merge(ax)
      end)
    end)
  end

  def find_path(map, start_loc, h) do
    start = %{Map.get(map, start_loc) | f: h.(start_loc, map.dest)}
    do_find_path(%{map | start_loc => start}, MapSet.new(), MapSet.new(), start, h)
  end

  defp build_path(_map, [%{parent: nil} | _] = acc), do: acc

  defp build_path(map, [%{parent: parent} | _] = acc),
    do: build_path(map, [map |> Map.get(parent) | acc])

  # handle start points with no viable path
  defp do_find_path(_map, _open, _closed, nil, _h), do: []

  defp do_find_path(map, _open, _closed, current, _h) when current.loc == map.dest,
    do: build_path(map, [Map.get(map, map.dest)])

  defp do_find_path(map, open, closed, current, h) do
    {map, open} =
      get_walkable_neighbors(map, current)
      |> Enum.filter(&(MapSet.member?(closed, &1.loc) == false))
      |> Enum.map(fn child ->
        g = current.g + distance(child.loc, current.loc)
        f = g + h.(child.loc, map.dest)

        unless MapSet.member?(open, child.loc) && g > Map.get(map, child.loc).g do
          %{child.loc => %{child | g: g, f: f, parent: current.loc}}
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.reduce({map, open}, fn nod, {map, open} ->
        {Map.merge(map, nod), MapSet.put(open, nod |> Map.keys() |> List.first())}
      end)

    open = MapSet.delete(open, current.loc)

    next =
      open
      |> Enum.map(&Map.get(map, &1))
      |> Enum.sort_by(& &1.f)
      |> List.first()

    do_find_path(map, open, MapSet.put(closed, current.loc), next, h)
  end

  def get_walkable_neighbors(map, %MapNode{loc: {lx, ly}, height: lh}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn {x, y} -> Map.get(map, {lx + x, ly + y}) end)
    |> Enum.filter(&(&1 && is_walkable?(lh, &1.height)))
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)
  end

  defp is_walkable?(from, to) do
    to - from <= 1
  end
end

defmodule AdventOfCode.Day12 do
  def part1(input) do
    map = HeightMap.new(input)

    path_length =
      HeightMap.find_path(map, map.start, fn _, _ -> 0 end)
      |> Enum.map(& &1.height)
      |> IO.inspect(label: "path", width: 1000)
      |> length()

    path_length - 1
  end

  def part2(input) do
    map = HeightMap.new(input)

    map
    |> Map.values()
    |> Enum.filter(&(is_map(&1) && &1.height == ?a))
    |> Enum.map(&(HeightMap.find_path(map, &1.loc, fn _, _ -> 0 end) |> length() |> Kernel.-(1)))
    |> Enum.filter(&(&1 > 0))
    |> Enum.min()
  end
end
