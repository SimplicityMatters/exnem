defmodule Exnem.Schema.TransferTransaction do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  @current_version 3

  embedded_schema do
    field(:size, :integer)
    field(:signature, :binary, default: String.pad_leading("", 64, "\0"))
    field(:signer, :binary, default: String.pad_leading("", 32, "\0"))
    field(:version, :integer, default: Exnem.version(@current_version))
    field(:type, :integer, default: Exnem.transaction_type(:transfer))
    field(:fee, :integer, default: 0)
    field(:deadline, :integer)
    field(:recipient, :binary)
    field(:message_size, :integer)
    field(:num_mosaics, :integer)
    embeds_one(:message, Exnem.Schema.Message)
    embeds_many(:mosaics, Exnem.Schema.Mosaic)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  def changeset(struct, attrs \\ %{}) do
    changeset =
      struct
      |> cast(attrs, [:deadline, :recipient])
      |> cast_embed(:message, required: true)
      |> cast_embed(:mosaics, required: true)
      |> validate_required([:fee, :deadline, :recipient, :version, :type])

    if changeset.valid? do
      mosaics = get_field(changeset, :mosaics)
      message_schema = get_field(changeset, :message)

      changeset
      |> put_change(:num_mosaics, length(mosaics))
      |> put_change(:message_size, byte_size(message_schema.payload) + 1)
      |> put_change(:size, 149 + length(mosaics) * 16 + byte_size(message_schema.payload))
    else
      changeset
    end
  end

  def sign_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:signature, :signer])
    |> validate_required([:signature, :signer])
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
      schema.recipient::binary,
      schema.message_size::little-unsigned-integer-16,
      schema.num_mosaics::little-unsigned-integer-8,
      schema.message |> Exnem.Schema.Message.pack()::binary,
      schema.mosaics
      |> Enum.sort()
      |> Enum.map(fn x -> Exnem.Schema.Mosaic.pack(x) end)
      |> Enum.join("")::binary
    >>
  end
end
