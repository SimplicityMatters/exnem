defmodule Exnem.Schema.MosaicDefinitionTransaction do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  @current_version 2
  # @max_supply 9_000_000_000_000_000

  embedded_schema do
    field(:version, :integer, default: Exnem.version(@current_version))
    field(:type, :integer, default: Exnem.transaction_type(:mosaic_definition))
    field(:fee, :integer, default: 0)
    field(:deadline, :integer)
    field(:parentId, :integer)
    field(:mosaicId, :integer)
    field(:duration, :integer)
    field(:mosaicName, :string)
    field(:divisibility, :integer)
    # field(:supply, :integer)
    field(:supplyMutable, :boolean)
    field(:transferable, :boolean)
    field(:levyMutable, :boolean)

    # Computed fields
    field(:size, :integer)
    field(:signature, :binary, default: String.pad_leading("", 64, "\0"))
    field(:signer, :binary, default: String.pad_leading("", 32, "\0"))
    field(:mosaicNameLength, :integer)
    field(:flags, :integer)

    field(:numOptionalProperties, :integer, default: 1)
    field(:indicateDuration, :integer, default: 2)
  end

  @fields [
    :deadline,
    :duration,
    :parentId,
    :mosaicId,
    :mosaicName,
    :divisibility,
    # :supply,
    :supplyMutable,
    :transferable,
    :levyMutable
  ]

  @required [
    :version,
    :type,
    :fee,
    :deadline,
    :duration,
    :parentId,
    :mosaicId,
    :mosaicName,
    :divisibility,
    # :supply,
    :supplyMutable,
    :transferable,
    :levyMutable
  ]

  def changeset(struct, attrs \\ %{}) do
    changeset =
      struct
      |> cast(attrs, @fields)
      |> validate_required(@required)

    # |> validate_max_supply()

    if changeset.valid? do
      mosaicNameLength = byte_size(changeset.changes.mosaicName)

      changeset
      |> put_change(:size, 149 + mosaicNameLength)
      |> put_change(:mosaicNameLength, mosaicNameLength)
      |> put_change(:flags, compute_flags(changeset.changes))
    else
      changeset
    end
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
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
      schema.parentId::little-unsigned-integer-64,
      schema.mosaicId::little-unsigned-integer-64,
      schema.mosaicNameLength::little-unsigned-integer-8,
      schema.numOptionalProperties::little-unsigned-integer-8,
      schema.flags::little-unsigned-integer-8,
      schema.divisibility::little-unsigned-integer-8,
      schema.mosaicName::binary,
      schema.indicateDuration::little-unsigned-integer-8,
      schema.duration::little-unsigned-integer-64
    >>
  end

  defp compute_flags(%{
         supplyMutable: supplyMutable,
         transferable: transferable,
         levyMutable: levyMutable
       }) do
    bit_1 =
      if supplyMutable do
        1
      else
        0
      end

    bit_2 =
      if transferable do
        2
      else
        0
      end

    bit_3 =
      if levyMutable do
        4
      else
        0
      end

    bit_1 + bit_2 + bit_3
  end

  # defp validate_max_supply(changeset) do
  #   if changeset.valid? do
  #     %{supply: supply, divisibility: divisibility} = changeset.changes
  #
  #     changeset
  #     |> validate_number(:supply, less_than_or_equal_to: max_supply(supply, divisibility))
  #   else
  #     changeset
  #   end
  # end
  #
  # defp max_supply(supply, divisibility) when is_integer(supply) and is_integer(divisibility) do
  #   case divisibility do
  #     0 ->
  #       @max_supply
  #
  #     _ ->
  #       scale = :math.pow(10, divisibility)
  #       round(supply / scale)
  #   end
  # end
end
