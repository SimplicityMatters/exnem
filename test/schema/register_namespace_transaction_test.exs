defmodule Exnem.Schema.RegisterNamespaceTransactionTest do
  use Exnem.Case

  import Exnem.Transaction, only: [register_root_namespace: 2, register_sub_namespace: 2, pack: 1]
  alias Exnem.Crypto.KeyPair

  describe "Register Namespace Transaction" do

    test "it can create root namespace transactions", %{test_keypair: keypair} do
      {:ok, schema} = register_root_namespace("newnamespace", 10000)

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(keypair)

      slice =
        verifiable.payload
        |> String.slice(240, byte_size(verifiable.payload))

      assert slice == "0010270000000000007EE9B3B8AFDF53400C6E65776E616D657370616365"
    end

    test "it can create sub namespace transactions", %{test_keypair: keypair} do
      {:ok, schema} = register_sub_namespace("newnamespace", "sub2")

      verifiable =
        schema
        |> pack()
        |> KeyPair.sign(keypair)

      slice =
        verifiable.payload
        |> String.slice(240, byte_size(verifiable.payload))

      assert slice == "017EE9B3B8AFDF5340AB31A2FF762DD6060473756232"
    end
  end
end
