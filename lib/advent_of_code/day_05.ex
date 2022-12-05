defmodule AdventOfCode.Day05 do
  def part1(input) do
    {stacks, steps} = parse_input(input)

    Enum.reduce(steps, stacks, &do_step/2) |> to_output()
  end

  def part2(input) do
    {stacks, steps} = parse_input(input)

    Enum.reduce(steps, stacks, &do_step_9001/2) |> to_output()
  end

  defp parse_input(input) do
    [stacks, steps] =
      input
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n"))

    {parse_stacks(stacks), parse_steps(steps)}
  end

  defp to_output(input) do
    input
    |> Map.values()
    |> Enum.map(&hd/1)
    |> Enum.join()
  end

  defp do_step([num, _from, _to], stacks) when num == 0, do: stacks

  defp do_step([num, from, to], stacks) do
    [head | tail] = stacks[from]
    stacks = Map.update!(stacks, to, &[head | &1]) |> Map.replace!(from, tail)
    do_step([num - 1, from, to], stacks)
  end

  defp do_step_9001([num, from, to], stacks) do
    {to_move, remaining} = stacks[from] |> Enum.split(num)
    Map.update!(stacks, to, &(to_move ++ &1)) |> Map.replace!(from, remaining)
  end

  defp parse_steps(steps) do
    steps |> Enum.filter(&not_empty/1) |> Enum.map(&parse_step/1)
  end

  defp parse_step(row) do
    row
    |> String.split(" ")
    |> tl()
    |> Enum.take_every(2)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_stacks(stacks) do
    {crates, number_row} = Enum.split(stacks, -1)
    col_count = hd(number_row) |> String.trim() |> String.last() |> String.to_integer()
    for col <- 0..(col_count - 1), into: %{}, do: {col + 1, parse_stack_col(crates, col)}
  end

  defp parse_stack_col(stacks, col) do
    stacks
    |> Enum.map(&String.slice(&1, col * 4 + 1, 1))
    |> Enum.filter(&not_empty/1)
  end

  defp not_empty(str), do: String.trim(str) != ""
end
