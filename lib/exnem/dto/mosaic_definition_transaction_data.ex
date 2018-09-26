defmodule Exnem.DTO.MosaicDefinitionTransactionData do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:signature, :binary)
    field(:signer, :binary)
    field(:version, :integer)
    field(:type, :integer)
    field(:fee, {:array, :integer})
    field(:deadline, {:array, :integer})
    field(:parentId, {:array, :integer})
    field(:mosaicId, {:array, :integer})
    # field(:duration, {:array, :integer})
    field(:name, :string)
    field(:divisibility, :integer)
    field(:flags, {:array, :integer})
  end

  @required_inner [
    :signer,
    :version,
    :type,
    :parentId,
    :mosaicId,
    :name
  ]
  @required @required_inner ++ [:signature, :fee, :deadline]

  def inner_changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, @required_inner)
    |> validate_required(@required_inner)
    # |> update_change(:duration, &Exnem.Uint64.join/1)
    |> update_change(:parentId, &Exnem.Uint64.join/1)
    |> update_change(:mosaicId, &Exnem.Uint64.join/1)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> update_change(:deadline, &Exnem.Uint64.join/1)
    |> update_change(:parentId, &Exnem.Uint64.join/1)
    |> update_change(:mosaicId, &Exnem.Uint64.join/1)
    # |> update_change(:duration, &Exnem.Uint64.join/1)
    |> update_change(:fee, &Exnem.Uint64.join/1)
  end
end
