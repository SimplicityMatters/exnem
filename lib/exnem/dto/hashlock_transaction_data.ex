defmodule Exnem.DTO.HashlockTransactionData do
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
    field(:duration, {:array, :integer})
    field(:mosaicId, {:array, :integer})
    field(:amount, {:array, :integer})
    field(:hash, :string)
  end

  @required [
    :signature,
    :signer,
    :version,
    :type,
    :fee,
    :deadline,
    :duration,
    :mosaicId,
    :amount,
    :hash
  ]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:hash, is: 64)
    |> update_change(:fee, &Exnem.Uint64.join/1)
    |> update_change(:deadline, &Exnem.Uint64.join/1)
    |> update_change(:duration, &Exnem.Uint64.join/1)
    |> update_change(:mosaicId, &Exnem.Uint64.join/1)
    |> update_change(:amount, &Exnem.Uint64.join/1)
  end
end
