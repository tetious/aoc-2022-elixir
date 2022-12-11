defmodule Monkey do
  defstruct [:key, :items, :action, :test, :test_do, :test_else, inspections: 0]

  def new(lines, monkey \\ %Monkey{})
  def new([], monkey), do: monkey

  def new([line | tail], monkey) do
    monkey = Map.merge(monkey, line |> parse_line() |> Map.new())
    new(tail, monkey)
  end

  def do_round(monkey, worry_adj) do
    outcomes =
      Enum.map(
        monkey.items,
        &(&1
          |> inspect_item(monkey)
          |> worry_adj.()
          |> determine_outcome(monkey))
      )

    {%{monkey | items: [], inspections: monkey.inspections + length(monkey.items)}, outcomes}
  end

  def throw_to(monkey, item) do
    %{monkey | items: List.insert_at(monkey.items, -1, item)}
  end

  defp inspect_item(item, monkey) do
    case monkey.action do
      "* old" -> item * item
      "+ old" -> item + item
      "* " <> n -> item * String.to_integer(n)
      "+ " <> n -> item + String.to_integer(n)
    end
  end

  defp determine_outcome(item, monkey) do
    if rem(item, monkey.test) == 0 do
      {monkey.test_do, item}
    else
      {monkey.test_else, item}
    end
  end

  defp parse_line(line) do
    case String.trim(line) do
      "Monkey " <> a ->
        [key: String.trim(a, ":") |> String.to_integer()]

      "Starting items: " <> a ->
        items = String.split(a, ",") |> Enum.map(&(String.trim(&1) |> String.to_integer()))
        [items: items]

      "Operation: new = old " <> op ->
        [action: op]

      "Test: divisible by " <> div ->
        [test: String.to_integer(div)]

      "If true: throw to monkey " <> dest ->
        [test_do: String.to_integer(dest)]

      "If false: throw to monkey " <> dest ->
        [test_else: String.to_integer(dest)]
    end
  end
end

defmodule AdventOfCode.Day11 do
  def part1(input) do
    input
    |> parse_monkeys()
    |> process_rounds(20, &div(&1, 3))
    |> calc_monkey_business()
  end

  def part2(input) do
    monkeys = input |> parse_monkeys()

    # special thanks to @blemelin for their explanation of the how to use modulo like this
    # https://github.com/blemelin/advent-of-code-2022/blob/main/src/day11.rs#L27
    # Math is hard. :|
    modulo =
      monkeys
      |> Enum.map(& &1.test)
      |> Enum.product()

    monkeys
    |> process_rounds(10_000, &rem(&1, modulo))
    |> calc_monkey_business()
  end

  defp parse_monkeys(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&(String.split(&1, "\n") |> Monkey.new()))
  end

  defp calc_monkey_business(monkeys) do
    monkeys
    |> Enum.map(& &1.inspections)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  defp process_rounds(monkeys, 0, _worry_adj), do: monkeys

  defp process_rounds(monkeys, r, worry_adj) do
    monkeys
    |> Enum.reduce(monkeys, &process_round(&1.key, &2, worry_adj))
    |> process_rounds(r - 1, worry_adj)
  end

  defp process_round(idx, monkeys, worry_adj) do
    {monkey, results} =
      monkeys
      |> Enum.at(idx)
      |> Monkey.do_round(worry_adj)

    results
    |> Enum.reduce(
      monkeys,
      fn {di, item}, monkeys ->
        List.update_at(monkeys, di, &Monkey.throw_to(&1, item))
      end
    )
    |> List.replace_at(monkey.key, monkey)
  end
end
