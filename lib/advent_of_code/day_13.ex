defmodule AdventOfCode.Day13 do
  def part1(input) do
    input
    |> String.trim()
    |> String.split()
    |> Enum.map(&JSON.decode!/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&in_order?(List.to_tuple(&1)))
    |> Enum.with_index()
    |> Enum.reduce(0, fn {in_order, i}, a -> if in_order, do: i + a + 1, else: a end)
  end

  def part2(input) do
    input
    |> String.trim()
    |> String.split()
    |> Enum.map(&JSON.decode!/1)
    |> Kernel.++([[[2]], [[6]]])
    |> Enum.sort(&in_order?({&1, &2}))
    |> calc_decoder_key()
  end

  defp calc_decoder_key(list) do
    (Enum.find_index(list, &(&1 == [[2]])) + 1) *
      (Enum.find_index(list, &(&1 == [[6]])) + 1)
  end

  defp in_order?({[], rhs}) when length(rhs) > 0, do: true
  defp in_order?({lhs, []}) when length(lhs) > 0, do: false
  defp in_order?({[], []}), do: :continue
  defp in_order?({lhs, rhs}) when is_list(lhs) and is_integer(rhs), do: in_order?({lhs, [rhs]})
  defp in_order?({lhs, rhs}) when is_integer(lhs) and is_list(rhs), do: in_order?({[lhs], rhs})

  defp in_order?({[lhs | lhs_tail], [rhs | rhs_tail]}) do
    if (result = in_order?({lhs, rhs})) == :continue do
      in_order?({lhs_tail, rhs_tail})
    else
      result
    end
  end

  defp in_order?({lhs, rhs}), do: if(lhs == rhs, do: :continue, else: lhs < rhs)
end
