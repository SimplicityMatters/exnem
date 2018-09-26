defmodule Exnem.Mosaic do
  def exists?(namespace, mosaic_name) do
    url = url(namespace, mosaic_name)

    case Exnem.Node.get(url) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def find(namespace, mosaic_name) do
    url = url(namespace, mosaic_name)

    with {:ok, data} <- Exnem.Node.get(url) do
      Exnem.DTO.MosaicInfo.new(data)
    end
  end

  def get_supply(namespace, mosaic_name) do
    with {:ok, info} <- find(namespace, mosaic_name) do
      {:ok, info.mosaic.supply}
    end
  end

  def hex_id(namespace, mosaic_name) do
    "#{namespace}:#{mosaic_name}"
    |> Exnem.mosaic_id()
    |> Integer.to_string(16)
  end

  defp url(namespace, mosaic_name) do
    "/mosaic/" <> hex_id(namespace, mosaic_name)
  end
end
