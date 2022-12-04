defmodule AdventOfCode.Day03 do
  def part1(input) do
    input
    |> get_pairs()
    |> Enum.map(&find_commons/1)
    |> Enum.map(&get_score/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.chunk_every(3)
    |> Enum.map(&find_commons/1)
    |> Enum.map(&get_score/1)
    |> Enum.sum()
  end

  defp get_pairs(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split_at(&1, mid_point(&1)))
  end

  defp mid_point(input) do
    input
    |> String.length()
    |> Integer.floor_div(2)
  end

  defp find_commons({a, b}) do
    find_commons(a, b)
  end

  defp find_commons([a, b, c]) do
    find_commons(a, b)
    |> MapSet.intersection(c |> make_charlist_mapset())
  end

  defp find_commons(a, b) do
    a
    |> make_charlist_mapset()
    |> MapSet.intersection(b |> make_charlist_mapset())
  end

  defp make_charlist_mapset(str) do
    str
    |> to_charlist()
    |> MapSet.new()
  end

  defp get_score(letters) when is_map(letters) do
    letters
    |> Enum.map(&get_score/1)
    |> Enum.sum()
  end

  defp get_score(letter) do
    if letter >= 97 do
      letter - 96
    else
      letter - 65 + 27
    end
  end
end
