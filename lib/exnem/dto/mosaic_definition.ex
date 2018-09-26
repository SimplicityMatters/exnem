defmodule Exnem.DTO.MosaicDefinition do
  use Bitwise
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:namespaceId, {:array, :integer})
    field(:mosaicId, {:array, :integer})
    field(:supply, {:array, :integer})
    field(:height, {:array, :integer})
    field(:owner, :string)
    field(:properties, {:array, {:array, :integer}})
    field(:levy, :map)
    field(:supplyMutable, :boolean, virtual: true)
    field(:transferable, :boolean, virtual: true)
    field(:levyMutable, :boolean, virtual: true)
    field(:duration, :integer, virtual: true)
  end

  @required [:namespaceId, :mosaicId, :supply, :height, :owner, :properties, :levy]

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @required)
    |> validate_required(@required)
    |> update_change(:namespaceId, &Exnem.Uint64.join/1)
    |> update_change(:mosaicId, &Exnem.Uint64.join/1)
    |> update_change(:supply, &Exnem.Uint64.join/1)
    |> update_change(:height, &Exnem.Uint64.join/1)
    |> update_properties()
  end

  defp update_properties(changeset) do
    if changeset.valid? do
      [
        [_, _] = flags,
        [_, _] = divisibility,
        [_, _] = duration
      ] = get_field(changeset, :properties)

      %{supplyMutable: supplyMutable, transferable: transferable, levyMutable: levyMutable} =
        parse_flags(flags)

      changeset
      |> put_change(:supplyMutable, supplyMutable)
      |> put_change(:transferable, transferable)
      |> put_change(:levyMutable, levyMutable)
      |> put_change(:divisibility, divisibility)
      |> put_change(:duration, duration)
    else
      changeset
    end
  end

  defp parse_flags([_, _] = flags) do
    value = Exnem.Uint64.join(flags)

    %{
      supplyMutable: (value &&& 1) != 0,
      transferable: (value &&& 2) != 0,
      levyMutable: (value &&& 4) != 0
    }
  end
end
