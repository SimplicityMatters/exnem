defmodule Exnem.DTO.Namespace do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:type, :integer)
    field(:depth, :integer)
    field(:level0, {:array, :integer})
    field(:level1, {:array, :integer})
    field(:level2, {:array, :integer})
    field(:parentId, {:array, :integer})
    field(:owner, :string)
    field(:ownerAddress, :string)
    field(:startHeight, {:array, :integer})
    field(:endHeight, {:array, :integer})
  end

  def new(params \\ %{}) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:insert)
  end

  @required [:type, :depth, :level0, :parentId, :owner, :ownerAddress, :startHeight, :endHeight]
  @fields (@required ++ [:level1, :level2])

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @fields)
    |> validate_required(@required)
    |> update_change(:level0, &Exnem.Uint64.join/1)
    |> update_change(:level1, &Exnem.Uint64.join/1)
    |> update_change(:level2, &Exnem.Uint64.join/1)
    |> update_change(:parentId, &Exnem.Uint64.join/1)
    |> update_change(:startHeight, &Exnem.Uint64.join/1)
    |> update_change(:endHeight, &Exnem.Uint64.join/1)
  end
end
