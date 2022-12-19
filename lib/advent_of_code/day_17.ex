defmodule ViewPort do
  defstruct x: 0, y: 0, width: 6

  def render(vp, board, new_piece) do
    IO.puts("\n\n")

    (board.top + 5)..0
    |> Enum.map(fn y ->
      x_range(vp)
      |> Enum.map(fn x ->
        cond do
          Board.intersects(board, {x, y}) -> "#"
          Piece.intersects(new_piece, {x, y}) -> "O"
          y == 0 -> "-"
          true -> "."
        end
        |> IO.write()
      end)

      IO.puts("")
    end)

    nil
  end

  defp x_range(vp), do: vp.x..(vp.x + vp.width)
end

defmodule Piece do
  @enforce_keys [:layout_idx, :loc, :width, :height]
  defstruct @enforce_keys

  @layouts %{
    0 => MapSet.new([{0, 0}, {1, 0}, {2, 0}, {3, 0}]),
    1 => MapSet.new([{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}]),
    2 => MapSet.new([{2, 2}, {2, 1}, {0, 0}, {1, 0}, {2, 0}]),
    3 => MapSet.new([{0, 0}, {0, 1}, {0, 2}, {0, 3}]),
    4 => MapSet.new([{0, 0}, {0, 1}, {1, 0}, {1, 1}])
  }

  def new(top, num) do
    layout_idx = rem(num, 5)
    layout = @layouts[layout_idx]
    width = layout |> Enum.max_by(&elem(&1, 0)) |> elem(0)
    height = layout |> Enum.max_by(&elem(&1, 1)) |> elem(1)
    %Piece{loc: {2, top + 4}, layout_idx: layout_idx, width: width, height: height + 1}
  end

  def intersects(piece, loc) do
    loc = piece |> offset(loc)
    if loc in @layouts[piece.layout_idx], do: true, else: false
  end

  def get(piece) do
    @layouts[piece.layout_idx] |> Enum.map(&add_points(&1, piece.loc)) |> MapSet.new()
  end

  defp offset(%{loc: {mx, my}}, {x, y}), do: {x - mx, y - my}
  defp add_points({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end

defmodule Board do
  defstruct resting: MapSet.new(), resting_count: 0, top: 0

  def intersects(board, loc) do
    loc in board.resting
  end

  def step(board, input, target, draft_idx) when board.resting_count < target do
    new_piece = Piece.new(board.top, board.resting_count)
    # ViewPort.render(%ViewPort{}, board, new_piece)
    do_step(board, input, target, draft_idx, :draft, new_piece)
  end

  def step(board, _input, _target, _), do: board

  defp do_step(board, input, target, draft_idx, :draft, piece) do
    {x, y} = piece.loc
    draft_offset = rem(draft_idx, input.drafts_len)
    draft_symbol = binary_slice(input.drafts, draft_offset, 1)
    new_x = if draft_symbol == "<", do: x - 1, else: x + 1

    updated = %{piece | loc: {new_x, y}}

    blocked =
      new_x < 0 || new_x + piece.width > 6 ||
        updated |> Piece.get() |> MapSet.intersection(board.resting) |> MapSet.size() > 0

    if blocked do
      # IO.inspect(draft_symbol, label: "draft blocked")
      do_step(board, input, target, draft_idx + 1, :down, piece)
    else
      # IO.inspect(draft_symbol, label: "draft")
      do_step(board, input, target, draft_idx + 1, :down, updated)
    end
  end

  defp do_step(board, input, target, draft_idx, :down, piece) do
    {x, y} = piece.loc
    new_y = y - 1
    updated = %{piece | loc: {x, new_y}}

    blocked =
      new_y == 0 ||
        updated |> Piece.get() |> MapSet.intersection(board.resting) |> MapSet.size() > 0

    if blocked do
      resting_pieces = MapSet.new(Enum.concat(board.resting, Piece.get(piece)))
      top = resting_pieces |> Enum.max_by(fn {_, y} -> y end) |> elem(1)

      resting_pieces =
        if board.resting_count > 0 && rem(board.resting_count, 64) == 0 do
          resting_pieces |> MapSet.filter(&(elem(&1, 1) > top - 32))
        else
          resting_pieces
        end

      # IO.inspect({piece, top}, label: "resting")
      step(
        %{board | top: top, resting: resting_pieces, resting_count: board.resting_count + 1},
        input,
        target,
        draft_idx
      )
    else
      # IO.inspect(y - 1, label: "fall")
      do_step(board, input, target, draft_idx, :draft, updated)
    end
  end
end

defmodule AdventOfCode.Day17 do
  def part1(input) do
    input = input |> String.trim()
    input = %{drafts: input, drafts_len: String.length(input)}
    board = Board.step(%Board{}, input, 2022, 0)
    board.top
  end

  def part2(input) do
    input = input |> String.trim()
    input = %{drafts: input, drafts_len: String.length(input)}
    # 1_000_000_000_000
    board = Board.step(%Board{}, input, 1_000_000, 0)
    board.top
  end
end
