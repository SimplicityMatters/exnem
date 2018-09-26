defmodule Exnem.DTO.NamespaceMosaicMeta do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:active, :boolean)
    field(:index, :integer)
    field(:id, :string)
  end

  @required [:active, :index, :id]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
