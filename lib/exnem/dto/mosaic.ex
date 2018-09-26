defmodule Exnem.DTO.Mosaic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:id, {:array, :integer})
    field(:amount, {:array, :integer})
  end

  def new(id, amount) do
    mosaic =
      %Exnem.DTO.Mosaic{}
      |> changeset(%{id: id, amount: amount})

    if mosaic.valid? do
      {:ok, mosaic |> apply_changes |> Map.from_struct()}
    else
      :error
    end
  end

  def changeset(mosaic, params \\ %{}) do
    mosaic
    |> cast(params, [:id, :amount])
    |> validate_required([:id, :amount])
    |> update_change(:id, &Exnem.Uint64.join/1)
    |> update_change(:amount, &Exnem.Uint64.join/1)
  end
end
