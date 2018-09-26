defmodule Exnem.Schema.MultisigModifyTransaction do
  use Ecto.Schema
  @primary_key false

  import Ecto.Changeset

  @current_version 3

  embedded_schema do
    field(:size, :integer)
    field(:signature, :binary, default: String.pad_leading("", 64, "\0"))
    field(:signer, :binary, default: String.pad_leading("", 32, "\0"))
    field(:version, :integer, default: Exnem.version(@current_version))
    field(:type, :integer, default: Exnem.transaction_type(:modify_multisig))
    field(:fee, :integer, default: 0)
    field(:deadline, :integer)
    field(:min_removal_delta, :integer)
    field(:min_approval_delta, :integer)
    field(:num_modifications, :integer)
    embeds_many(:modifications, Exnem.Schema.MultisigModification)
  end

  @fields [:version, :type, :fee, :deadline, :min_removal_delta, :min_approval_delta]
  @required [
    :version,
    :type,
    :fee,
    :deadline,
    :min_removal_delta,
    :min_approval_delta
  ]

  def changeset(struct, params \\ %{}) do
    changeset =
      struct
      |> cast(params, @fields)
      |> cast_embed(:modifications, required: true)
      |> validate_required(@required)

    if changeset.valid? do
      changeset
      |> put_change(:num_modifications, length(params.modifications))
      |> put_change(:size, 123 + 33 * length(params.modifications))
    else
      changeset
    end
  end

  def create(params \\ %{}) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:insert)
  end

  def pack(%__MODULE__{} = schema) do
    <<
      schema.size::little-unsigned-integer-32,
      schema.signature::binary,
      schema.signer::binary,
      schema.version::little-unsigned-integer-16,
      schema.type::little-unsigned-integer-16,
      schema.fee::little-unsigned-integer-64,
      schema.deadline::little-unsigned-integer-64,
      schema.min_removal_delta::little-unsigned-integer-8,
      schema.min_approval_delta::little-unsigned-integer-8,
      schema.num_modifications::little-unsigned-integer-8,
      schema.modifications
      |> Enum.map(&Exnem.Schema.MultisigModification.pack/1)
      |> Enum.join("")::binary
    >>
  end
end
