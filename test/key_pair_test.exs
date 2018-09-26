defmodule Exnem.KeyPairTest do
  use ExUnit.Case

  import Exnem
  alias Exnem.Crypto.KeyPair, as: KeyPair

  setup_all do
    {:ok,
     private_keys: [
       "8D31B712AB28D49591EAF5066E9E967B44507FC19C3D54D742F7B3A255CFF4AB",
       "15923F9D2FFFB11D771818E1F7D7DDCD363913933264D58533CB3A5DD2DAA66A",
       "A9323CEF24497AB770516EA572A0A2645EE2D5A75BC72E78DE534C0A03BC328E",
       "D7D816DA0566878EE739EDE2131CD64201BCCC27F88FA51BA5815BCB0FE33CC8",
       "27FC9998454848B987FAD89296558A34DEED4358D1517B953572F3E0AAA0A22D"
     ],
     input_data: [
       "8ce03cd60514233b86789729102ea09e867fc6d964dea8c2018ef7d0a2e0e24bf7e348e917116690b9",
       "e4a92208a6fc52282b620699191ee6fb9cf04daf48b48fd542c5e43daa9897763a199aaa4b6f10546109f47ac3564fade0",
       "13ed795344c4448a3b256f23665336645a853c5c44dbff6db1b9224b5303b6447fbf8240a2249c55",
       "a2704638434e9f7340f22d08019c4c8e3dbee0df8dd4454a1d70844de11694f4c8ca67fdcb08fed0cec9abb2112b5e5f89",
       "d2488e854dbcdfdb2c9d16c8c0b2fdbc0abb6bac991bfe2b14d359a6bc99d66c00fd60d731ae06d0"
     ],
     public_keys: [
       "53C659B47C176A70EB228DE5C0A0FF391282C96640C2A42CD5BBD0982176AB1B",
       "3FE4A1AA148F5E76891CE924F5DC05627A87047B2B4AD9242C09C0ECED9B2338",
       "F398C0A2BDACDBD7037D2F686727201641BBF87EF458F632AE2A04B4E8F57994",
       "6A283A241A8D8203B3A1E918B1E6F0A3E14E75E16D4CFFA45AE4EF89E38ED6B5",
       "4DC62B38215826438DE2369743C6BBE6D13428405025DFEFF2857B9A9BC9D821"
     ],
     signatures: [
       "C9B1342EAB27E906567586803DA265CC15CCACA411E0AEF44508595ACBC47600D02527F2EED9AB3F28C856D27E30C3808AF7F22F5F243DE698182D373A9ADE03",
       "0755E437ED4C8DD66F1EC29F581F6906AB1E98704ECA94B428A25937DF00EC64796F08E5FEF30C6F6C57E4A5FB4C811D617FA661EB6958D55DAE66DDED205501",
       "15D6585A2A456E90E89E8774E9D12FE01A6ACFE09936EE41271AA1FBE0551264A9FF9329CB6FEE6AE034238C8A91522A6258361D48C5E70A41C1F1C51F55330D",
       "F6FB0D8448FEC0605CF74CFFCC7B7AE8D31D403BCA26F7BD21CB4AC87B00769E9CC7465A601ED28CDF08920C73C583E69D621BA2E45266B86B5FCF8165CBE309",
       "E88D8C32FE165D34B775F70657B96D8229FFA9C783E61198A6F3CCB92F487982D08F8B16AB9157E2EFC3B78F126088F585E26055741A9F25127AC13E883C9A05"
     ]}
  end

  test "Derive public key from private", glob do
    public_keys =
      glob[:private_keys]
      |> Enum.map(&KeyPair.derive_public_key/1)

    assert public_keys == glob[:public_keys]
  end

  def sign_test_vectors(input_data, private_keys) do
    inputs = Enum.zip(input_data, private_keys)

    inputs
    |> Enum.map(fn {data, priv} ->
      KeyPair.sign(data |> from_hex, priv, :hex)
    end)
  end

  test "Can sign test vectors", glob do
    signatures = sign_test_vectors(glob[:input_data], glob[:private_keys])

    assert signatures == glob[:signatures]
  end

  test "Can verify test vectors", glob do
    inputs = Enum.zip([glob[:input_data], glob[:private_keys], glob[:public_keys]])

    signatures =
      inputs
      |> Enum.map(fn {data, priv, pub} ->
        {data, pub, KeyPair.sign(data |> from_hex, priv)}
      end)
      |> Enum.map(fn {data, pub, sign} ->
        KeyPair.verify(sign, data |> from_hex, pub)
      end)

    assert signatures == List.duplicate(true, length(signatures))
  end

  test "can create address from valid encoded address" do
    encoded = "NAR3W7B4BCOZSZMFIZRYB3N5YGOUSWIYJCJ6HDFG"
    expectedHex = "6823BB7C3C089D996585466380EDBDC19D4959184893E38CA6"

    decoded = KeyPair.stringToAddress(encoded)

    assert KeyPair.is_valid_address(decoded) == true
    assert to_hex(decoded) == expectedHex
  end

  test "can create address from public key for well known network" do
    expectedHex = "6023BB7C3C089D996585466380EDBDC19D49591848B3727714"
    public_key = "3485D98EFD7EB07ADAFCFD1A157D89DE2796A95E780813C0258AF3F5F84ED8CB"

    raw =
      KeyPair.public_key_to_address(public_key, :mijin)
      |> from_b32

    <<raw_id::bytes-size(1), _::binary>> = raw
    mijin_id = network_type(:mijin) |> :binary.encode_unsigned()

    assert raw_id == mijin_id
    assert KeyPair.is_valid_address(raw) == true
    assert to_hex(raw) == expectedHex
  end
end
