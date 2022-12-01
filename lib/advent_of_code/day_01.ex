defmodule AdventOfCode.Day01 do
  def part1(list) do
    list
    |> parse_input()
    |> Enum.max()
  end

  def part2(list) do
    list
    |> parse_input()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp parse_input(str) do
    str
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&for n <- String.split(&1, "\n"), do: String.to_integer(n))
    |> Enum.map(&Enum.sum/1)
  end
end
