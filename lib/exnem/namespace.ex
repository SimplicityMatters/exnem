defmodule Exnem.Namespace do
  def id_exists?(namespace_id) when is_integer(namespace_id) do
    namespace_id
    |> Integer.to_string(16)
    |> id_exists?()
  end

  def id_exists?(hex) when is_binary(hex) do
    case Exnem.Node.get("/namespace/" <> hex) do
      {:ok, _} ->
        true

      {:error, _} ->
        false
    end
  end

  def name_exists?(name) when is_binary(name) do
    name
    |> hex_id()
    |> id_exists?()
  end

  def find(name) do
    with {:ok, data} <- Exnem.Node.get("/namespace/" <> hex_id(name)) do
      Exnem.DTO.NamespaceInfo.new(data)
    end
  end

  def hex_id(name) when is_binary(name) do
    name
    |> Exnem.namespace_id()
    |> Integer.to_string(16)
  end
end
