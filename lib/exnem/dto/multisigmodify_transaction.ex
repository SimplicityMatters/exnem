defmodule Exnem.DTO.MultisigModifyTransaction do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    embeds_one(:meta, Exnem.DTO.TransactionMeta)
    embeds_one(:transaction, Exnem.DTO.MultisigModifyTransactionData)
  end

  def new(params \\ %{}) do
    changeset = changeset(%__MODULE__{}, params)

    if changeset.valid? do
      {:ok, changeset |> apply_changes()}
    else
      {:error, changeset}
    end
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [])
    |> cast_embed(:meta, required: true)
    |> cast_embed(:transaction, required: true)
  end
end
