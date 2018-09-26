defmodule Exnem.DTO.AccountInfo do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    field(:meta, :map)
    embeds_one(:account, Exnem.DTO.AccountData)
  end

  def changeset(changeset, attrs \\ %{}) do
    changeset
    |> cast(attrs, [])
    |> cast_embed(:account, required: true)
  end

  def new(attrs \\ %{}) do
    %Exnem.DTO.AccountInfo{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end
end
