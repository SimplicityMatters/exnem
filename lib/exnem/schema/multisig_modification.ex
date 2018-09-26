defmodule Exnem.Schema.MultisigModification do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:type, :integer)
    field(:cosignatory_public_key, :binary)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  def modifyType(:add), do: 0
  def modifyType(:remove), do: 1

  def changeset(mosaic, params \\ %{}) do
    mosaic
    |> cast(params, [:type, :cosignatory_public_key])
    |> validate_required([:type, :cosignatory_public_key])
  end

  def pack(%__MODULE__{} = schema) do
    <<
      schema.type::little-unsigned-integer-8,
      schema.cosignatory_public_key::binary
    >>
  end
end
