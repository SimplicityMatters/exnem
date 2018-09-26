defmodule Exnem.DTO.NamespaceInfo do
  use Ecto.Schema
  import Ecto.Changeset

  alias Exnem.DTO.NamespaceMosaicMeta
  alias Exnem.DTO.Namespace

  @primary_key false

  embedded_schema do
    embeds_one(:meta, NamespaceMosaicMeta)
    embeds_one(:namespace, Namespace)
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
    |> cast_embed(:namespace, required: true)
  end
end
