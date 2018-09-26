defmodule Exnem.DTO.TransactionMeta do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:hash, :string)
    field(:height, {:array, :integer})
    field(:id, :string)
    field(:index, :integer)
    field(:merkleComponentHash, :string)
  end

  @required [:hash, :height, :merkleComponentHash]
  # made this optional for transaction coming in over the websocket
  @optional [:id, :index]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> update_change(:height, &Exnem.Uint64.join/1)
  end
end
