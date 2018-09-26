defmodule Exnem.Crypto do
  import Exnem, only: [to_hex: 1]

  def create_hash(signed_bytes) do
    <<
      _::bytes-size(4),
      a::bytes-size(32),
      _::bytes-size(32),
      b::binary
    >> = signed_bytes

    (a <> b)
    |> sha3_256()
    |> to_hex()
  end

  def sha3_256(x), do: :keccakf1600.hash(:sha3_256, x)
end
