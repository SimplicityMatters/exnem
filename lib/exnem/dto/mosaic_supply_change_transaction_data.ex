defmodule Exnem.DTO.MosaicSupplyChangeTransactionData do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:signer, :binary)
    field(:version, :integer)
    field(:type, :integer)
    field(:fee, :integer)
    field(:deadline, {:array, :integer})
    field(:mosaicId, {:array, :integer})
    field(:direction, :integer)
    field(:delta, {:array, :integer})
  end

  @required_inner [
    :signer,
    :version,
    :type,
    :direction,
    :mosaicId,
    :delta
  ]
  @required @required_inner ++ [:signature, :fee, :deadline]

  def inner_changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, @required_inner)
    |> validate_required(@required_inner)
    |> update_change(:mosaicId, &Exnem.Uint64.join/1)
    |> update_change(:delta, &Exnem.Uint64.join/1)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> update_change(:deadline, &Exnem.Uint64.join/1)
    |> update_change(:mosaicId, &Exnem.Uint64.join/1)
    |> update_change(:fee, &Exnem.Uint64.join/1)
    |> update_change(:delta, &Exnem.Uint64.join/1)
  end
end
