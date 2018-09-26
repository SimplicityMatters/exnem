defmodule Exnem.DTO.AggregateTransactionData do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:signature, :string)
    field(:signer, :string)
    field(:version, :integer)
    field(:type, :integer)
    field(:fee, {:array, :integer})
    field(:deadline, {:array, :integer})
    embeds_many(:cosignatures, Exnem.DTO.AggregateTransactionCosignature)
    embeds_many(:transactions, Exnem.DTO.InnerTransaction)
  end

  @required [:deadline, :fee, :signature, :signer, :type, :version]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> cast_embed(:transactions)
    |> cast_embed(:cosignatures)
    |> update_change(:deadline, &Exnem.Uint64.join/1)
    |> update_change(:fee, &Exnem.Uint64.join/1)
  end
end
