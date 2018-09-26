defmodule Exnem.DTO.BlockData do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:signature, :string)
    field(:signer, :string)
    field(:version, :integer)
    field(:type, :integer)
    field(:height, {:array, :integer})
    field(:timestamp, {:array, :integer})
    field(:difficulty, {:array, :integer})
    field(:previousBlockHash, :string)
    field(:blockTransactionsHash, :string)
  end

  @required [
    :signature,
    :signer,
    :version,
    :type,
    :height,
    :timestamp,
    :difficulty,
    :previousBlockHash,
    :blockTransactionsHash
  ]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> update_change(:height, &Exnem.Uint64.join/1)
    |> update_change(:timestamp, &Exnem.Uint64.join/1)
    |> update_change(:difficulty, &Exnem.Uint64.join/1)
  end
end
