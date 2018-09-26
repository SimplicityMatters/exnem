defmodule Exnem.DTO.TransferTransactionData do
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
    field(:recipient, :string)
    embeds_one(:message, Exnem.DTO.Message)
    embeds_many(:mosaics, Exnem.DTO.Mosaic)
  end

  @required_inner [:signer, :version, :type, :recipient]
  @required @required_inner ++ [:signature, :fee, :deadline]

  def inner_changeset(params \\ %{}) do
    %Exnem.DTO.TransferTransactionData{}
    |> cast(params, @required_inner)
    |> validate_required(@required_inner)
    |> cast_embed(:message, required: true)
    |> cast_embed(:mosaics)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> cast_embed(:message, required: true)
    |> cast_embed(:mosaics, required: true)
    |> update_change(:deadline, &Exnem.Uint64.join/1)
    |> update_change(:fee, &Exnem.Uint64.join/1)
  end
end
