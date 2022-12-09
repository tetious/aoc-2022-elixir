defmodule Rope do
  defstruct knots: [], tail_visited: MapSet.new()

  def new(knots) do
    %Rope{knots: List.duplicate({0, 0}, knots)}
  end

  def move(rope, [dir, dist]) when is_binary(dist), do: move(rope, [dir, String.to_integer(dist)])
  def move(rope, [_dir, dist]) when dist == 0, do: rope
  def move(rope, [dir, dist]), do: move_head(rope, dir) |> move([dir, dist - 1])

  defp move_head(rope, dir) do
    [{h_x, h_y} | tail] = rope.knots

    head =
      case dir do
        "R" -> {h_x + 1, h_y}
        "L" -> {h_x - 1, h_y}
        "U" -> {h_x, h_y + 1}
        "D" -> {h_x, h_y - 1}
      end

    knots = [head | tail] |> propagate()
    %{rope | knots: knots, tail_visited: MapSet.put(rope.tail_visited, List.last(knots))}
  end

  defp propagate(knots), do: propagate(knots, [hd(knots)])

  defp propagate(rest, out) when length(rest) == 1, do: out |> Enum.reverse()

  defp propagate([{h_x, h_y}, {t_x, t_y} | rest], out) do
    tail =
      case {h_x - t_x, h_y - t_y} do
        {d_x, d_y} when abs(d_x) + abs(d_y) > 2 -> {t_x + clamp(d_x), t_y + clamp(d_y)}
        {d_x, 0} when abs(d_x) == 2 -> {t_x + clamp(d_x), t_y}
        {0, d_y} when abs(d_y) == 2 -> {t_x, t_y + clamp(d_y)}
        _ -> {t_x, t_y}
      end

    propagate([tail | rest], [tail | out])
  end

  defp clamp(num) do
    cond do
      num > 0 -> 1
      num < 0 -> -1
      true -> 0
    end
  end
end

defmodule AdventOfCode.Day09 do
  def part1(input) do
    rope =
      input
      |> String.split()
      |> Enum.chunk_every(2)
      |> Enum.reduce(Rope.new(2), fn step, rope -> Rope.move(rope, step) end)

    MapSet.size(rope.tail_visited)
  end

  def part2(input) do
    rope =
      input
      |> String.split()
      |> Enum.chunk_every(2)
      |> Enum.reduce(Rope.new(10), fn step, rope -> Rope.move(rope, step) end)

    MapSet.size(rope.tail_visited)
  end
end
