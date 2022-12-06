defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&(String.to_charlist(&1) |> find_marker(4)))
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&(String.to_charlist(&1) |> find_marker(14)))
  end

  defp find_marker(stream, size), do: find_marker(0, stream, size, -1)

  defp find_marker(set_length, _stream, size, pos) when set_length == size, do: pos + size

  defp find_marker(_set_length, stream, size, pos) do
    stream
    |> Enum.take(size)
    |> MapSet.new()
    |> MapSet.size()
    |> find_marker(tl(stream), size, pos + 1)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
  end
end
