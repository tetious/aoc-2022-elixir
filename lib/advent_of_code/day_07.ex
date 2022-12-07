defmodule AdventOfCode.Day07 do
  @elf_device_size 70_000_000
  @update_requires 30_000_000

  @spec part1(binary) :: number
  def part1(input) do
    input
    |> recursive_size()
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  def part2(input) do
    [root_size | rest] =
      input
      |> recursive_size()
      |> Enum.sort(:desc)

    free_space = @elf_device_size - root_size

    rest
    |> Enum.filter(&(free_space + &1 > @update_requires))
    |> List.last()
  end

  defmodule ElfFile do
    @enforce_keys [:name, :size]
    defstruct [:name, :size]
  end

  defmodule ElfDirectory do
    @enforce_keys [:name]
    defstruct [:name, contents: []]

    @spec size(%ElfDirectory{}) :: integer()
    def size(dir) do
      dir.contents |> Enum.reduce(0, fn fil, acc -> acc + fil.size end)
    end
  end

  defp build_filesystem(input) do
    input
    |> String.split()
    |> parse_line()
  end

  defp recursive_size(input) do
    filesystem = build_filesystem(input)

    filesystem
    |> Map.keys()
    |> Enum.map(&recursive_size(filesystem, &1))
  end

  defp recursive_size(filesystem, dir) do
    filesystem
    |> Map.keys()
    # nested directories
    |> Enum.filter(&(Enum.take(&1, -length(dir)) == dir))
    |> Enum.map(&ElfDirectory.size(filesystem[&1]))
    |> Enum.sum()
  end

  defp parse_line(["$", "cd", "/" | tail]) do
    parse_line(tail, ["/"], %{["/"] => %ElfDirectory{name: "/"}})
  end

  defp parse_line([], _cur_path, filesystem), do: filesystem

  defp parse_line(["$", "cd", ".." | tail], cur_path, filesystem) do
    parse_line(tail, tl(cur_path), filesystem)
  end

  defp parse_line(["$", "cd", dir_name | tail], cur_path, filesystem) do
    parse_line(tail, [dir_name | cur_path], filesystem)
  end

  defp parse_line(["$", "ls" | tail], cur_path, filesystem),
    do: parse_line(tail, cur_path, filesystem)

  defp parse_line(["dir", name | tail], cur_path, filesystem) do
    parse_line(tail, cur_path, Map.put(filesystem, [name | cur_path], %ElfDirectory{name: name}))
  end

  defp parse_line([size, name | tail], cur_path, filesystem) do
    parse_line(
      tail,
      cur_path,
      put_in(filesystem[cur_path].contents, [
        %ElfFile{name: name, size: String.to_integer(size)} | filesystem[cur_path].contents
      ])
    )
  end
end
