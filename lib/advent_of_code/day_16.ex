defmodule MapNode do
  @enforce_keys [:loc, :rate, :edges]
  defstruct [:loc, :rate, :edges, parent: nil, g: 0]
end

defmodule ValveMap do
  @input_regex ~r/^Valve (\w{2}) has flow rate=(\d+); tunnels? leads? to valves? (.+)$/m

  def new(input) do
    Regex.scan(@input_regex, input, capture: :all_but_first)
    |> Enum.reduce(%{}, fn [v, r, edges], a ->
      Map.put(a, v, %MapNode{loc: v, rate: String.to_integer(r), edges: String.split(edges, ", ")})
    end)
  end

  def find_path(map, start, dest) do
    do_find_path(map, MapSet.new(), MapSet.new(), Map.get(map, start), dest)
  end

  defp build_path(_map, [%{parent: nil} | _] = acc), do: length(acc)

  defp build_path(map, [%{parent: parent} | _] = acc),
    do: build_path(map, [map |> Map.get(parent) | acc])

  # path is found, spit it out
  defp do_find_path(map, _open, _closed, current, dest) when current.loc == dest,
    do: build_path(map, [Map.get(map, dest)])

  defp do_find_path(map, open, closed, current, dest) do
    {map, open} =
      current.edges
      # |> Enum.filter(& &1.loc == current)
      |> Enum.map(&Map.get(map, &1))
      |> Enum.filter(&(MapSet.member?(closed, &1.loc) == false))
      |> Enum.reduce([], fn child, list ->
        g = current.g + 1

        if MapSet.member?(open, child.loc) && g > Map.get(map, child.loc).g do
          list
        else
          [%{child.loc => %{child | g: g, parent: current.loc}} | list]
        end
      end)
      |> Enum.reduce({map, open}, fn nod, {map, open} ->
        {Map.merge(map, nod), MapSet.put(open, nod |> Map.keys() |> List.first())}
      end)

    open = MapSet.delete(open, current.loc)

    next =
      open
      |> Enum.map(&Map.get(map, &1))
      |> Enum.sort_by(& &1.g)
      |> List.first()

    do_find_path(map, open, MapSet.put(closed, current.loc), next, dest)
  end
end

defmodule AdventOfCode.Day16 do
  def part1(input) do
    map =
      input
      |> ValveMap.new()

    to_open =
      map
      |> Map.values()
      |> Enum.filter(&(&1.rate > 0))
      |> Enum.map(&{&1.loc, 0, 30})

    d = optimal_path(map, {"AA", 0, 30}, calc_options(map, "AA", to_open), [])
    IO.inspect(d)
  end

  def part2(_args) do
  end

  defp optimal_path(_map, _current, [], best), do: best
  defp optimal_path(_map, {_, _, time}, _, best) when time <= 0, do: best
  # defp optimal_path(_map, nil, _, best), do: best
  # defp optimal_path(_map, _current, _open, [{nil, 0, 0} | tail]), do: tail

  defp optimal_path(map, current, to_open, best) do
    v_loc = elem(current, 0)

    to_open =
      calc_options(
        map,
        v_loc,
        to_open |> Enum.filter(&(elem(&1, 0) != v_loc))
      )

    best_child = to_open |> best()
    IO.inspect({to_open, best_child})
    optimal_path(map, best_child, to_open, [best_child | best])
  end

  defp best([]), do: {nil, 0, 0}
  defp best(list), do: list |> Enum.max_by(&elem(&1, 1))

  defp calc_options(map, current, closed, costs \\ [])
  defp calc_options(_map, _current, [], costs), do: costs

  defp calc_options(map, current, [{dest_loc, _, time} | closed], costs) do
    dest_rate = Map.get(map, dest_loc).rate
    cost = ValveMap.find_path(map, current, dest_loc)
    remaining = time - cost

    calc_options(
      map,
      current,
      closed,
      if(remaining > 0,
        do: [{dest_loc, dest_rate * remaining, remaining} | costs],
        else: costs
      )
    )
  end
end
