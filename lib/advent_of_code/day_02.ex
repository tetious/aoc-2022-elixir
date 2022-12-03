defmodule AdventOfCode.Day02 do
  def part1(input) do
    input
    |> parse()
    |> Enum.map(&score_1/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse()
    |> Enum.map(&score_2/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
  end

  defp score_1([a, b]) do
    case {a, b} do
      {"A", "X"} -> 1 + 3
      {"A", "Y"} -> 2 + 6
      {"A", "Z"} -> 3

      {"B", "X"} -> 1
      {"B", "Y"} -> 2 + 3
      {"B", "Z"} -> 3 + 6

      {"C", "X"} -> 1 + 6
      {"C", "Y"} -> 2
      {"C", "Z"} -> 3 + 3
    end
  end

    defp score_2([a, b]) do
    case {a, b} do
      {"A", "X"} -> 3
      {"A", "Y"} -> 1 + 3
      {"A", "Z"} -> 2 + 6

      {"B", "X"} -> 1
      {"B", "Y"} -> 2 + 3
      {"B", "Z"} -> 3 + 6

      {"C", "X"} -> 2
      {"C", "Y"} -> 3 + 3
      {"C", "Z"} -> 1 + 6
    end
  end
end
