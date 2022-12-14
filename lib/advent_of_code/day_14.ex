defmodule LineSegment do
  def new(pairs) do
    pairs
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&to_range_seg/1)
  end

  def intersects(seg, {x, y}) do
    seg |> Enum.any?(fn {xs, ys} -> x in xs && y in ys end)
  end

  def any_intersects(segs, point), do: Enum.any?(segs, &LineSegment.intersects(&1, point))

  defp to_range_seg([{x1, y1}, {x2, y2}]) do
    {x1..x2, y1..y2}
  end
end

defmodule ViewPort do
  defstruct x: 480, y: 0, width: 60, height: 200

  def render(vp, segs, resting_sand) do
    vp
    |> y_range()
    |> Enum.map(fn y ->
      x_range(vp)
      |> Enum.map(fn x ->
        point = {x, y}

        cond do
          point in resting_sand -> IO.write("O")
          LineSegment.any_intersects(segs, {x, y}) -> IO.write("#")
          true -> IO.write(".")
        end
      end)

      IO.puts("")
    end)

    nil
  end

  defp x_range(vp), do: vp.x..(vp.x + vp.width)
  defp y_range(vp), do: vp.y..(vp.y + vp.height)
end

defmodule AdventOfCode.Day14 do
  @void_y 200

  def part1(input) do
    input
    |> parse()
    |> Enum.map(&LineSegment.new/1)
    |> drop_sand(@void_y + 1)
    |> MapSet.size()
  end

  def part2(input) do
    segs =
      input
      |> parse()

    floor_y = (segs |> List.flatten() |> Enum.map(&elem(&1, 1)) |> Enum.max()) + 2

    segs
    |> Enum.map(&LineSegment.new/1)
    |> drop_sand(floor_y)
    |> MapSet.size()

    # 29805
    # 164.97 -- sloooow
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn seg ->
      String.split(seg, " -> ")
      |> Enum.map(fn pair ->
        String.split(pair, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)
    end)
  end

  defp drop_sand(segs, floor_y) do
    resting_sand = MapSet.new()
    do_drop(segs, resting_sand, floor_y, {500, 0}, nil)
  end

  defp do_drop(_segs, resting_sand, _floor_y, {_, @void_y}, _) do
    # ViewPort.render(%ViewPort{}, segs, resting_sand)
    resting_sand
  end

  defp do_drop(_segs, resting_sand, _floor_y, nil, {500, 0}) do
    # ViewPort.render(%ViewPort{}, segs, resting_sand)
    resting_sand
  end

  defp do_drop(segs, resting_sand, floor_y, nil, _),
    do: do_drop(segs, resting_sand, floor_y, {500, 0}, nil)

  defp do_drop(segs, resting_sand, floor_y, {x, y} = prev_point, _) do
    can_move = gen_can_move(segs, resting_sand, floor_y)

    point =
      cond do
        can_move.(pt = {x, y + 1}) -> pt
        can_move.(pt = {x - 1, y + 1}) -> pt
        can_move.(pt = {x + 1, y + 1}) -> pt
        true -> nil
      end

    resting_sand = if point == nil, do: MapSet.put(resting_sand, prev_point), else: resting_sand
    do_drop(segs, resting_sand, floor_y, point, prev_point)
  end

  defp gen_can_move(segs, resting_sand, floor_y),
    do: fn {_, y} = point ->
      y < floor_y && point not in resting_sand && LineSegment.any_intersects(segs, point) == false
    end
end
