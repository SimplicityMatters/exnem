defmodule Exnem.Schema.AggregateTransaction do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  alias Exnem.Crypto.KeyPair

  import Exnem, only: [from_hex: 1]

  @current_version 2

  embedded_schema do
    field(:size, :integer)
    field(:signature, :binary, default: String.pad_leading("", 64, "\0"))
    field(:signer, :binary, default: String.pad_leading("", 32, "\0"))
    field(:version, :integer, default: Exnem.version(@current_version))
    field(:type, :integer, default: Exnem.transaction_type(:aggregate_complete))
    field(:fee, :integer, default: 0)
    field(:deadline, :integer)
    field(:transactions_size, :integer)
    # Exnem.Schema.TransferTranaction
    field(:transactions, :binary)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  def changeset(struct, params \\ %{}) do
    changeset =
      struct
      |> cast(params, [:version, :type, :deadline])
      # |> cast_embed(:transactions, required: true)
      |> validate_required([:version, :type, :deadline])
      # 0 !== this.transactions.length ? this.transactions.length : 4294967296
      |> put_change(:transactions, List.foldl(params.transactions, <<>>, &Kernel.<>/2))

    hack = byte_size(changeset.changes.transactions)

    changeset
    |> put_change(:transactions_size, hack)
    |> put_change(:size, 120 + 4 + hack)
  end

  # def sign_changeset(changeset, params \\ %{}) do
  #   changeset
  #   |> cast(params, [:signature, :signer])
  #   |> validate_required([:signature, :signer])
  # end

  def pack_for_signing(%__MODULE__{} = schema) do
    <<
      schema.version::little-unsigned-integer-16,
      schema.type::little-unsigned-integer-16,
      schema.fee::little-unsigned-integer-64,
      schema.deadline::little-unsigned-integer-64,
      schema.transactions_size::little-unsigned-integer-32,
      schema.transactions::binary
    >>
  end

  def pack(%__MODULE__{} = schema) do
    <<
      schema.size::little-unsigned-integer-32,
      schema.signature::binary,
      schema.signer::binary
    >> <> pack_for_signing(schema)
  end

  # def create_and_sign(aggregate_transaction, key_pair) do
  #   data_changeset =
  #     aggregate_transaction
  #     |> create_changeset()
  #
  #   true = data_changeset.valid?
  #
  #   signature =
  #     data_changeset
  #     |> Ecto.Changeset.apply_changes()
  #     |> pack_for_signing()
  #     |> KeyPair.sign(key_pair.private_key)
  #
  #   additions = %{
  #     signature: signature,
  #     signer: key_pair.public_key |> from_hex
  #   }
  #
  #   changeset =
  #     data_changeset
  #     |> sign_changeset(additions)
  #
  #   true = changeset.valid?
  #
  #   changeset
  #   |> Ecto.Changeset.apply_changes()
  #   |> pack()
  # end
  #
  # # Should be able to take 'any' transaction type.  This is a transformation between packed representations
  # def convert_for_aggregation(payload, public_key) when is_raw(public_key) do
  #   payload = payload |> from_hex
  #   sss_size = 4 + 64 + 32
  #
  #   <<_size_signature_signer::bytes-size(sss_size), version_type::bytes-size(4),
  #     _fee_deadline::bytes-size(16), rest::binary>> = payload
  #
  #   new_payload = public_key <> version_type <> rest
  #
  #   <<
  #     byte_size(new_payload) + 4::little-unsigned-integer-32,
  #     new_payload::binary
  #   >>
  # end
  #
  # def convert_for_aggregation(payload, public_key) when is_address(public_key) do
  #   convert_for_aggregation(payload, from_address(public_key))
  # end
  #
  # def convert_for_aggregation(payload, public_key) when is_base32(public_key) do
  #   convert_for_aggregation(payload, from_b32(public_key))
  # end
  #
  # def convert_for_aggregation(payload, public_key) when is_hex(public_key) do
  #   convert_for_aggregation(payload, from_hex(public_key))
  # end

  # treats the bytes like a transaction hash
  def sign_cosignatories_transaction(signed, key_pairs) do
    hash = signed.hash |> from_hex
    payload = signed.payload |> from_hex

    payload =
      key_pairs
      |> List.foldl(payload, fn kp, acc ->
        # sign the hash
        signature = KeyPair.sign(hash, kp.private_key)
        # append to payload
        acc <> from_hex(kp.public_key) <> signature
      end)

    <<_size::bytes-size(4), tail::binary>> = payload

    <<
      byte_size(tail) + 4::little-unsigned-integer-32,
      tail::binary
    >>
  end
end
