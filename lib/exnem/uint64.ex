defmodule Exnem.Uint64 do
  @doc """
  Joins specified high and low order 32-bit values to create a 64-bit Integer.
  """
  def join([low, high]) do
    low + high * 0x100000000
  end

  @doc """
  Splits the specified number into high and low order 32-bit values.
  """
  def split(number) when is_integer(number) do
    <<high::unsigned-integer-32, low::unsigned-integer-32>> = :binary.encode_unsigned(number)
    [low, high]
  end
end
