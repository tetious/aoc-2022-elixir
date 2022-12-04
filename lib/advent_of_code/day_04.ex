defmodule AdventOfCode.Day04 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&intersects(&1, :and))
    |> Enum.count(& &1)
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&intersects(&1, :or))
    |> Enum.count(& &1)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&split_pairs/1)
  end

  defp intersects({pair, pair}, _), do: true

  defp intersects(pairs, :and), do: intersects(pairs, &Kernel.and/2)

  defp intersects({s1..e1, s2..e2}, op)
       when is_function(op) and (s1 > s2 or (s1 == s2 and e2 > e1)) do
    op.(Enum.member?(s2..e2, s1), Enum.member?(s2..e2, e1))
  end

  defp intersects(pairs, :or), do: intersects(pairs, &Kernel.or/2)

  defp intersects({s1..e1, s2..e2}, op)
       when is_function(op) and (s2 > s1 or (s1 == s2 and e1 > e2)) do
    op.(Enum.member?(s1..e1, s2), Enum.member?(s1..e1, e2))
  end

  defp split_pairs(sections) do
    [one, two] = String.split(sections, ",")
    {to_range(one), to_range(two)}
  end

  defp to_range(range) do
    [first, last] = String.split(range, "-") |> Enum.map(&String.to_integer/1)
    Range.new(first, last)
  end
end
