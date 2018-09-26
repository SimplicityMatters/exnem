defmodule Exnem.DTO.InnerTransactionMeta do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:height, {:array, :integer})
    field(:id, :string)
    field(:index, :integer)
    field(:aggregateId, :string)
    field(:aggregateHash, :string)
  end

  @required [:height, :id, :index, :aggregateId, :aggregateHash]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> update_change(:height, &Exnem.Uint64.join/1)
  end
end
