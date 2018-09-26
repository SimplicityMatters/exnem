defmodule Exnem.Schema.MosaicSupplyChangeTransaction do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  @current_version 2
  @max_supply 9_000_000_000_000_000

  embedded_schema do
    field(:version, :integer, default: Exnem.version(@current_version))
    field(:type, :integer, default: Exnem.transaction_type(:mosaic_supply_change))
    field(:fee, :integer, default: 0)
    field(:deadline, :integer)
    field(:mosaicId, :integer)
    field(:direction, :integer)
    field(:delta, :integer, default: @max_supply)

    field(:size, :integer, default: 137)
    field(:signature, :binary, default: String.pad_leading("", 64, "\0"))
    field(:signer, :binary, default: String.pad_leading("", 32, "\0"))
  end

  @fields [
    :deadline,
    :mosaicId,
    :direction,
    :delta
  ]

  @required [
    :deadline,
    :mosaicId,
    :direction,
    :delta
  ]

  def changeset(changeset, attrs \\ %{}) do
    changeset
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def pack(%__MODULE__{} = schema) do
    <<
      schema.size::little-unsigned-integer-32,
      schema.signature::bytes-size(64),
      schema.signer::bytes-size(32),
      schema.version::little-unsigned-integer-16,
      schema.type::little-unsigned-integer-16,
      schema.fee::little-unsigned-integer-64,
      schema.deadline::little-unsigned-integer-64,
      schema.mosaicId::little-unsigned-integer-64,
      schema.direction::little-unsigned-integer-8,
      schema.delta::little-unsigned-integer-64
    >>
  end
end
