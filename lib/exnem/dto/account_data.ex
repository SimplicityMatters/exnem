defmodule Exnem.DTO.AccountData do
  use Ecto.Schema
  import Ecto.Changeset

  alias Exnem.Uint64

  @primary_key false

  embedded_schema do
    field(:address, :string)
    field(:addressHeight, {:array, :integer})
    field(:publicKey, :string)
    field(:publicKeyHeight, {:array, :integer})
    field(:importance, {:array, :integer})
    field(:importanceHeight, {:array, :integer})
    embeds_many(:mosaics, Exnem.DTO.Mosaic)
  end

  def changeset(changeset, attrs \\ %{}) do
    changeset
    |> cast(attrs, [:address, :addressHeight, :publicKey, :publicKeyHeight])
    |> cast_embed(:mosaics)
    |> update_change(:addressHeight, &Uint64.join/1)
    |> update_change(:publicKeyHeight, &Uint64.join/1)
    |> update_change(:importance, &Uint64.join/1)
    |> update_change(:importanceHeight, &Uint64.join/1)
  end
end
