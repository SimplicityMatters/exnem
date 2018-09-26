defmodule Exnem.Schema.MosaicDefinitionTransactionTest do
  use Exnem.Case

  import Exnem.Transaction, only: [mosaic_definition: 3, pack: 1]
  alias Exnem.Crypto.KeyPair

  describe "Mosaic Definition Transaction" do
    test "it should create a mosaic definition transaction", %{test_keypair: keypair} do
      {:ok, schema} =
        mosaic_definition(
          "sname",
          "mosaics",
          duration: 10000,
          divisibility: 4,
          supplyMutable: true
        )

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(keypair)

      slice =
        verifiable.payload
        |> String.slice(240, byte_size(verifiable.payload))

      assert slice == "9B8A161CF5092390159911AEA72EBD3C070101046D6F7361696373021027000000000000"
    end
  end
end
