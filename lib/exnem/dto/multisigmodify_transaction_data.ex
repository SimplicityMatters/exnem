defmodule Exnem.DTO.MultisigModifyTransactionData do
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
    field(:minApprovalDelta, :integer)
    field(:minRemovalDelta, :integer)
    embeds_many(:modifications, Exnem.DTO.MultisigModification)
  end

  @required_inner [:signer, :version, :type, :minApprovalDelta, :minRemovalDelta]
  @required @required_inner ++ [:signature, :fee, :deadline]

  def inner_changeset(attrs \\ %{}) do
    %Exnem.DTO.MultisigModifyTransactionData{}
    |> cast(attrs, @required_inner)
    |> validate_required(@required_inner)
    |> cast_embed(:modifications, required: true)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> cast_embed(:modifications, required: true)
    |> update_change(:deadline, &Exnem.Uint64.join/1)
    |> update_change(:fee, &Exnem.Uint64.join/1)
  end
end
