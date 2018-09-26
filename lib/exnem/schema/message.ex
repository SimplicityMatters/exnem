defmodule Exnem.Schema.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  embedded_schema do
    field(:type, :integer)
    field(:payload, :string, default: "")
  end

  def create_plain(attrs) do
    %Exnem.Schema.Message{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:payload])
    |> validate_length(:payload, max: 1024)
    |> put_change(:type, 0)
  end

  def pack(schema) do
    msg = <<schema.type::little-integer-8>>

    case schema.payload do
      nil ->
        msg

      "" ->
        msg

      _ ->
        msg <> <<schema.payload::binary>>
    end
  end
end
