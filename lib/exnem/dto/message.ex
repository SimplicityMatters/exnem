defmodule Exnem.DTO.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  embedded_schema do
    field(:type, :integer)
    field(:payload, :string)
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:type, :payload])
    |> validate_required([:type])
    |> update_change(:payload, &handle_empty_string/1)
    |> update_change(:payload, &Exnem.from_hex/1)
  end

  defp handle_empty_string(string) do
    if string == nil do
      ""
    else
      string
    end
  end
end
