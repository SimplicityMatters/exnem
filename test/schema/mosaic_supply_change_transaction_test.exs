defmodule Exnem.Schema.MosaicSupplyChangeTransactionTest do
  use Exnem.Case

  import Exnem.Transaction, only: [supply_change: 4, pack: 1]
  alias Exnem.Crypto.KeyPair

  describe "Supply Change Transaction" do
    test "it should create a mosaic supply change transaction", %{test_keypair: keypair} do
      {:ok, schema} = supply_change(:increase, "sname", "mosaics3", 10)

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(keypair)

      slice = String.slice(verifiable.payload, 240, byte_size(verifiable.payload))

      assert slice == "8869746E9B1A7057010A00000000000000"
    end
  end
end
