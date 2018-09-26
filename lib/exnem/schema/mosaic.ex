defmodule Exnem.Schema.Mosaic do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  embedded_schema do
    field(:id, :integer)
    field(:amount, :integer)
  end

  def create(attrs) do
    %Exnem.Schema.Mosaic{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  def changeset(mosaic, params \\ %{}) do
    mosaic
    |> cast(params, [:id, :amount])
    |> validate_required([:id, :amount])
  end

  def pack(schema) do
    <<
      schema.id::little-unsigned-integer-64,
      schema.amount::little-unsigned-integer-64
    >>
  end
end
