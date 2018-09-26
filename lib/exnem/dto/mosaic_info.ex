defmodule Exnem.DTO.MosaicInfo do
  use Ecto.Schema
  import Ecto.Changeset

  alias Exnem.DTO.MosaicDefinition
  alias Exnem.DTO.NamespaceMosaicMeta

  @primary_key false

  embedded_schema do
    embeds_one(:meta, NamespaceMosaicMeta)
    embeds_one(:mosaic, MosaicDefinition)
  end

  def new(params \\ %{}) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:insert)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [])
    |> cast_embed(:meta, required: true)
    |> cast_embed(:mosaic, required: true)
  end
end
