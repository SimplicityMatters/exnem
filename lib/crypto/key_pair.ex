defmodule Exnem.Crypto.KeyPair do
  import Exnem
  import Exnem.Crypto

  @doc """
    > derive_public_key()
  """
  def derive_public_key(private_key) when is_hex(private_key) do
    private_key
    |> from_hex
    |> derive_public_key
  end

  def derive_public_key(private_key) when is_raw(private_key) do
    private_key
    |> Kcl.derive_public_key(:sign)
    |> to_hex
  end

  @doc """
    > public_key_to_address()
  """
  def public_key_to_address(public_key, network_type) when is_hex(public_key) do
    public_key
    |> from_hex
    |> public_key_to_address(network_type)
  end

  def public_key_to_address(public_key, network_type) when is_raw(public_key) do
    hashed_key = sha3_256(public_key)
    ripe_hash = :crypto.hash(:ripemd160, hashed_key)

    network_id =
      network_type
      |> network_type()
      |> :binary.encode_unsigned()

    unchecked_address = network_id <> ripe_hash

    <<checksum::bytes-size(4), _::binary>> = sha3_256(unchecked_address)

    to_b32(unchecked_address <> checksum)
  end

  @doc """
    > KeyPair.is_valid_address("NAR3W7B4BCOZSZMFIZRYB3N5YGOUSWIYJCJ6HDFG")
    true
  """
  def is_valid_address(address) when byte_size(address) == 25 do
    <<address_head::bytes-size(21), received_checksum::bytes-size(4)>> = address

    <<head_checksum::bytes-size(4), _::binary>> = sha3_256(address_head)

    head_checksum == received_checksum
  end

  def stringToAddress(encoded_address) do
    encoded_address |> from_b32()
  end

  def sign(input, private_key) when is_hex(private_key) do
    sign(input, private_key |> from_hex)
  end

  def sign(input, private_key) when is_raw(private_key) do
    Kcl.sign(input, private_key)
  end

  def sign(packed_bytes, %{public_key: signer, private_key: private_key})
      when is_binary(packed_bytes) do
    <<
      size::little-unsigned-integer-32,
      _signature::binary-64,
      _signer::binary-32,
      signable_bytes::binary
    >> = packed_bytes

    signature = sign(signable_bytes, private_key)
    signer = signer |> from_hex

    payload = <<
      size::little-unsigned-integer-32,
      signature::binary-64,
      signer::binary-32,
      signable_bytes::binary
    >>

    %{
      payload: payload |> to_hex(),
      hash: create_hash(payload)
    }
  end

  def sign(packed_bytes, %{public_key: _, private_key: _} = initiator, cosigners: cosigners) do
    verifiable =
      packed_bytes
      |> sign(initiator)

    hash = verifiable.hash |> from_hex
    payload = verifiable.payload |> from_hex

    payload =
      cosigners
      |> List.foldl(payload, fn kp, acc ->
        # sign the hash
        signature = sign(hash, kp.private_key)
        # append to payload
        acc <> from_hex(kp.public_key) <> signature
      end)

    <<_size::bytes-size(4), tail::binary>> = payload

    payload = <<
      byte_size(tail) + 4::little-unsigned-integer-32,
      tail::binary
    >>

    %{
      payload: payload |> to_hex(),
      hash: verifiable.hash
    }
  end

  def sign(input, private_key, :hex) do
    sign(input, private_key)
    |> to_hex()
  end

  def verify(signature, message, public_key) when is_hex_signature(signature) do
    verify(signature |> from_hex, message, public_key)
  end

  def verify(signature, message, public_key) when is_hex(public_key) do
    verify(signature, message, public_key |> from_hex)
  end

  def verify(signature, message, public_key)
      when is_raw(public_key) and is_raw_signature(signature) do
    Kcl.valid_signature?(signature, message, public_key)
  end

  def verify(signature, message, public_key, :hex) do
    verify(signature, message, public_key)
    |> to_hex()
  end

  def generate_key() do
    :crypto.strong_rand_bytes(32)
  end

  def generate_key(:hex) do
    generate_key()
    |> to_hex()
  end

  def generate() do
    private_key = generate_key()

    public_key =
      private_key
      |> derive_public_key()

    %{
      private_key: private_key |> to_hex,
      public_key: public_key
    }
  end

  def generate(network_type) do
    key_pair = generate()

    address =
      key_pair.public_key
      |> public_key_to_address(network_type)
      |> formatted_address()

    Map.put(key_pair, :address, address)
  end
end
