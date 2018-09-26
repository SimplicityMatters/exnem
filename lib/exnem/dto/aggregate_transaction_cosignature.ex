defmodule Exnem.DTO.AggregateTransactionCosignature do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:signature, :string)
    field(:signer, :string)
  end

  @required [:signature, :signer]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
