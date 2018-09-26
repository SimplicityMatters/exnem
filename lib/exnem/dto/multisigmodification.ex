defmodule Exnem.DTO.MultisigModification do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:type, :integer)
    field(:cosignatoryPublicKey, :string)
  end

  @required [:type, :cosignatoryPublicKey]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
