defmodule Exnem.Duration do
  alias Exnem.Config

  def to_blocks(number, :second) do
    (number / Config.block_duration()) |> quantize()
  end

  def to_blocks(number, :minute) do
    (number * 60) |> to_blocks(:second)
  end

  def to_blocks(number, :hour) do
    (number * 3600) |> to_blocks(:second)
  end

  def to_blocks(number, :day) do
    (number * 86400) |> to_blocks(:second)
  end

  def from_blocks(number_blocks) do
    number_blocks * Config.block_duration()
  end

  defp quantize(value), do: value |> Float.ceil() |> round()
end
