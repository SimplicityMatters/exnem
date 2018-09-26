defmodule Exnem.DTO.BlockInfo do
  use Ecto.Schema
  @primary_key false
  import Ecto.Changeset

  embedded_schema do
    embeds_one(:meta, Exnem.DTO.BlockMeta)
    embeds_one(:block, Exnem.DTO.BlockData)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [])
    |> cast_embed(:meta, required: true)
    |> cast_embed(:block, required: true)
  end

  def new(params \\ %{}) do
    changeset =
      %Exnem.DTO.BlockInfo{}
      |> changeset(params)

    if changeset.valid? do
      {:ok, changeset |> apply_changes()}
    else
      {:error, changeset}
    end
  end
end
