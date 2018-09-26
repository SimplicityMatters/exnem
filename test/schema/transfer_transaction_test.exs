defmodule Exnem.Schema.TransferTransactionTest do
  use Exnem.Case

  import Exnem.Transaction, only: [transfer: 3, mosaic: 2, pack: 1]
  alias Exnem.Crypto.KeyPair

  describe "Transfer Transaction" do
    test "it should create a transfer transaction", %{test_keypair: keypair} do
      recipient = "SDUP5PLHDXKBX3UU5Q52LAY4WYEKGEWC6IB3VBFM"

      mosaics =
        with {:ok, mosaic1} <- mosaic(15_358_872_602_548_358_953, 100),
             {:ok, mosaic2} <- mosaic(637_801_466_534_309_632, 100),
             {:ok, mosaic3} <- mosaic(4_202_990_315_812_765_508, 100) do
          [mosaic1, mosaic2, mosaic3]
        end

      {:ok, schema} = transfer(recipient, mosaics, message: "00")

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(keypair)

      slice =
        verifiable.payload
        |> String.slice(240, byte_size(verifiable.payload))

      assert slice ==
               "90E8FEBD671DD41BEE94EC3BA5831CB608A312C2F203BA84AC030003003" <>
                 "030002F00FA0DEDD9086400000000000000443F6D806C05543A640000000000000029C" <>
                 "F5FD941AD25D56400000000000000"
    end
  end
end
