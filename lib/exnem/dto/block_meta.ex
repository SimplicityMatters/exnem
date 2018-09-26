defmodule Exnem.DTO.BlockMeta do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:hash, :string)
    field(:generationHash, :string)
    field(:totalFee, {:array, :integer}, default: 0)
    field(:numTransactions, :integer, default: 0)
  end

  @required [:hash, :generationHash, :totalFee, :numTransactions]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> update_change(:totalFee, &Exnem.Uint64.join/1)
  end
end
