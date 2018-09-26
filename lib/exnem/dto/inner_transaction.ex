defmodule Exnem.DTO.InnerTransaction do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    embeds_one(:meta, Exnem.DTO.InnerTransactionMeta)
    field(:transaction, :map)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:transaction])
    |> cast_embed(:meta)
    |> validate_required([:transaction])
    # we validated that it exists.
    |> cast_inner_transaction(params["transaction"])
  end

  def cast_inner_transaction(changeset, attrs) do
    inner_changeset =
      case Exnem.transaction_name(attrs["type"]) do
        :modify_multisig ->
          Exnem.DTO.MultisigModifyTransactionData.inner_changeset(attrs)

        :transfer ->
          Exnem.DTO.TransferTransactionData.inner_changeset(attrs)

        :register_namespace ->
          Exnem.DTO.RegisterNamespaceTransactionData.inner_changeset(attrs)

        :mosaic_definition ->
          Exnem.DTO.MosaicDefinitionTransactionData.inner_changeset(attrs)

        :mosaic_supply_change ->
          Exnem.DTO.MosaicSupplyChangeTransactionData.inner_changeset(attrs)

        :secret_lock ->
          raise "Support for InnerTransaction type :secret_lock is not yet implemented"

        :secret_proof ->
          raise "Support for InnerTransaction type :secret_proof is not yet implemented"

        _ ->
          changeset
          |> add_error(:transaction, "Transaction 'type' is required")
      end

    if inner_changeset.valid? do
      changeset
      |> put_change(:transaction, apply_changes(inner_changeset))
    end
  end
end
