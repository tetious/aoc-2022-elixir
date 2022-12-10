defmodule Cpu do
  defstruct x: 1, cycles: 1, crt: false, vram: [], log_steps: MapSet.new(), step_log: []

  def run(%{instruction: "noop"}, cpu), do: tick(cpu)
  def run(%{instruction: "addx", cycles: 1, params: p1}, cpu), do: tick(cpu, %{x: cpu.x + p1})

  def run(%{cycles: left} = instr, cpu) when left > 1,
    do: run(%{instr | cycles: instr.cycles - 1}, tick(cpu))

  defp tick(cpu, mut \\ %{}) do
    cpu
    |> log_trace()
    |> draw_pixel()
    |> Map.merge(mut)
    |> Map.merge(%{cycles: cpu.cycles + 1})
  end

  defp log_trace(cpu) do
    if MapSet.member?(cpu.log_steps, cpu.cycles) do
      %{cpu | step_log: [{cpu.cycles, cpu.x} | cpu.step_log]}
    else
      cpu
    end
  end

  defp draw_pixel(cpu) do
    x = cpu.cycles - 1 |> rem(40)

    cond do
      cpu.crt == false -> cpu
      x == cpu.x or abs(x - cpu.x) == 1 -> %{cpu | vram: ["#" | cpu.vram]}
      true -> %{cpu | vram: ["." | cpu.vram]}
    end
  end
end

defmodule Opcode do
  @enforce_keys [:instruction, :cycles]
  defstruct [:instruction, :cycles, params: []]

  @supported_opcodes %{"addx" => 2, "noop" => 1}

  def new(line) do
    [instruction | params] = String.split(line)

    %Opcode{
      instruction: instruction,
      cycles: @supported_opcodes[instruction],
      params: if(length(params) == 1, do: hd(params) |> String.to_integer(), else: nil)
    }
  end
end

defmodule AdventOfCode.Day10 do
  def part1(input) do
    input
    |> exec(%Cpu{log_steps: MapSet.new([20, 60, 100, 140, 180, 220])})
    |> Map.get(:step_log)
    |> Enum.map(&Tuple.product/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> exec(%Cpu{crt: true})
    |> Map.get(:vram)
    |> Enum.reverse()
    |> Enum.chunk_every(40)
    |> Enum.map(&IO.puts/1)
  end

  defp exec(input, cpu) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Opcode.new/1)
    |> Enum.reduce(cpu, fn op, cpu -> Cpu.run(op, cpu) end)
  end
end
