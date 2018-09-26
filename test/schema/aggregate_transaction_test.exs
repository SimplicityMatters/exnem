defmodule Exnem.Schema.AggregateTransactionTest do
  use Exnem.Case

  import Exnem.Transaction,
    only: [transfer: 3, mosaic: 2, convert_to_inner: 2, aggregate: 1, pack: 1]

  alias Exnem.Crypto.KeyPair

  describe "Aggregate Transaction" do
    setup do
      %{
        test_keypair: %{
          public_key: "846B4439154579A5903B1459C9CF69CB8153F6D0110A7A0ED61DE29AE4810BF2",
          private_key: "239CCE2C5D2B83A70DC91AFEF0CE325FC9947FAA87C8B18473092CE6A745945A"
        }
      }
    end

    test "it should create aggregate transfer transactions", %{test_keypair: keypair} do
      {:ok, mosaic} = mosaic(15_358_872_602_548_358_953, 10_000_000)

      {:ok, transfer} =
        transfer("SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC", [mosaic], message: "00")

      packed_inner = transfer |> convert_to_inner(keypair.public_key)

      {:ok, schema} =
        aggregate([
          packed_inner,
          packed_inner,
          packed_inner
        ])

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(keypair)

      slice =
        verifiable.payload
        |> String.slice(240, byte_size(verifiable.payload))

      expected =
        "0501000057000000846B4439154579A5903B1459C9CF69CB8153F6D0110A7A0ED61DE29AE4810B" <>
          "F2039054419050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E14203000100303029CF5FD941AD25D5809" <>
          "698000000000057000000846B4439154579A5903B1459C9CF69CB8153F6D0110A7A0ED61DE29AE4810BF2039054" <>
          "419050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E14203000100303029CF5FD941AD25D580969800000" <>
          "0000057000000846B4439154579A5903B1459C9CF69CB8153F6D0110A7A0ED61DE29AE4810BF2039054419050B9" <>
          "837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E14203000100303029CF5FD941AD25D58096980000000000"

      assert slice == expected
    end
  end

  describe "Aggregate Transaction with Co-signers" do
    setup do
      %{
        alice_keypair: %{
          address: "SDHSRBVCG5YVGTZM56DASS2MJ66B4GOCQ2YR4W2F",
          public_key: "cf893ffcc47c33e7f68ab1db56365c156b0736824a0c1e273f9e00b8df8f01eb",
          private_key: "2a2b1f5d366a5dd5dc56c3c757cf4fe6c66e2787087692cf329d7a49a594658b"
        },
        bob_keypair: %{
          address: "SBE6CS7LZKJXLDVTNAC3VZ3AUVZDTF3PACNFIXFN",
          public_key: "68b3fbb18729c1fde225c57f8ce080fa828f0067e451a3fd81fa628842b0b763",
          private_key: "b8afae6f4ad13a1b8aad047b488e0738a437c7389d4ff30c359ac068910c1d59"
        },
        multisig_account: %{
          address: "SBCPGZ3S2SCC3YHBBTYDCUZV4ZZEPHM2KGCP4QXX",
          public_key: "b694186ee4ab0558ca4afcfdd43b42114ae71094f5a1fc4a913fe9971cacd21d",
          private_key: "5edebfdbeb32e9146d05ffd232c8af2cf9f396caf9954289daa0362d097fff3b"
        }
      }
    end

    test "it should create aggregate transfer transactions with cosigners", %{
      alice_keypair: alice,
      bob_keypair: bob,
      multisig_account: multisig
    } do
      {:ok, mosaic} = mosaic(15_358_872_602_548_358_953, 100)

      {:ok, transfer} =
        transfer("SBILTA367K2LX2FEXG5TFWAS7GEFYAGY7QLFBYKC", [mosaic], message: "test")

      {:ok, schema} =
        transfer
        |> convert_to_inner(multisig.public_key)
        |> aggregate()

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(alice, cosigners: [bob])

      slice =
        verifiable.payload
        |> String.slice(240, byte_size(verifiable.payload) - 240 - 128)

      expected =
        "5900000059000000B694186EE4AB0558CA4AFCFDD43B42114AE71094F5A1FC4A913FE9971CACD21D039" <>
          "054419050B9837EFAB4BBE8A4B9BB32D812F9885C00D8FC1650E142050001007465737429CF5FD941AD25D5640000000" <>
          "000000068B3FBB18729C1FDE225C57F8CE080FA828F0067E451A3FD81FA628842B0B763"

      assert slice == expected
    end
  end
end
