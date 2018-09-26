defmodule Exnem do
  @moduledoc """
    Context for Catapult API wrapper.
  """
  require Logger

  def node_url() do
    Application.fetch_env!(:exnem, :node_url)
  end

  @doc """
    iex> Exnem.normalize_address("NAR3W7-B4BCOZ-SZMFIZ-RYB3N5-YGOUSW-IYJCJ6-HDFG")
    "NAR3W7B4BCOZSZMFIZRYB3N5YGOUSWIYJCJ6HDFG"
  """
  def normalize_address(address) do
    String.replace(address, "-", "")
  end

  @doc """
    iex> Exnem.formatted_address("NAR3W7B4BCOZSZMFIZRYB3N5YGOUSWIYJCJ6HDFG")
    "NAR3W7-B4BCOZ-SZMFIZ-RYB3N5-YGOUSW-IYJCJ6-HDFG"
  """
  def formatted_address(address) do
    <<a::bytes-size(6), b::bytes-size(6), c::bytes-size(6), d::bytes-size(6), e::bytes-size(6),
      f::bytes-size(6), g::bytes-size(4)>> = address

    Enum.join([a, b, c, d, e, f, g], "-")
  end

  @doc """
    > hex_address
  """
  def hex_address(address) do
    address
    |> from_address()
    |> to_hex()
  end

  @network_types [
    main_net: 0x68,
    test_net: 0x98,
    mijin: 0x60,
    mijin_test: 0x90
  ]

  @doc """
  Get the value for the configured network type. Default: :mijin_test

  Example Config:
  config :exnem, network_type: :mijin_test

  Available types are:
    * :main_net
    * :test_net
    * :mijin_test
    * :mijin

  iex> Exnem.network_type()
  0x90
  """
  def network_type() do
    key = Application.fetch_env!(:exnem, :network_type)
    Keyword.fetch!(@network_types, key)
  end

  def network_type(type) do
    Keyword.fetch!(@network_types, type)
  end

  @doc """
  Get the value for the specific type
  """

  @transaction_types [
    transfer: 0x4154,
    modify_multisig: 0x4155,
    aggregate_complete: 0x4141,
    aggregate_bonded: 0x4241,
    lock: 0x414C,
    register_namespace: 0x414E,
    mosaic_definition: 0x414D,
    mosaic_supply_change: 0x424D
    # Not yet implemented
    # secret_lock: 0x424C,
    # secret_proof: 0x434C
  ]

  for entry <- @transaction_types do
    {atom, value} = entry
    def transaction_type(unquote(atom)), do: unquote(value)
    def transaction_name(unquote(value)), do: unquote(atom)
  end

  def transaction_types do
    @transaction_types
  end

  @epoch DateTime.from_unix!(1_459_468_800_000, :millisecond)
  @deadline Application.get_env(:exnem, :default_deadline, 60 * 60 * 1000)

  # Duration is in milliseconds
  def deadline(deadline_duration \\ @deadline) do
    network_time = DateTime.diff(DateTime.utc_now(), @epoch, :millisecond)

    network_time + deadline_duration
  end

  def version(transaction_version, :hex) do
    network_version =
      network_type()
      |> Integer.to_string(16)

    transaction_version =
      transaction_version
      |> Integer.to_string(16)
      |> String.pad_leading(2, "0")

    network_version <> transaction_version
  end

  def version(transaction_version) do
    version(transaction_version, :hex)
    |> String.to_integer(16)
  end

  def mosaic_id(name) do
    [namespace, mosaic] = String.split(name, ":")
    namespace_id = namespace_id(namespace)

    generate_id(namespace_id, mosaic)
  end

  def namespace_id(name) do
    name
    |> generate_namespace_path()
    |> List.last()
  end

  def generate_namespace_path(name) do
    parts = String.split(name, ".")

    parts
    |> Enum.reduce([0], fn part, all ->
      part_id = generate_id(List.last(all), part)

      all ++ [part_id]
    end)
  end

  def generate_id(parentId, name) do
    result =
      :keccakf1600.init(:sha3_256)
      |> :keccakf1600.update(<<parentId::little-unsigned-64>>)
      |> :keccakf1600.update(name)
      |> :keccakf1600.final()

    <<namespace_id::little-unsigned-64, _::binary>> = result

    namespace_id
  end

  def namespace_type(:root), do: 0
  def namespace_type(:sub), do: 1

  def from_hex(hex), do: Base.decode16!(hex, case: :mixed)
  def from_b32(b32), do: Base.decode32!(b32, case: :mixed)
  def from_address(address), do: normalize_address(address) |> from_b32

  def to_hex(value), do: Base.encode16(value, case: :upper)
  def to_b32(value), do: Base.encode32(value, case: :upper)

  defguard is_hex(key) when byte_size(key) == 64
  defguard is_address(key) when byte_size(key) == 46 or byte_size(key) == 40
  defguard is_base32(key) when byte_size(key) == 40
  defguard is_raw(key) when byte_size(key) == 32

  defguard is_hex_signature(signature) when byte_size(signature) == 128
  defguard is_raw_signature(signature) when byte_size(signature) == 64
end
