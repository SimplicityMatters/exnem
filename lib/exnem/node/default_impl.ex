defmodule Exnem.Node.Impl.DefaultImpl do
  @moduledoc false
  @behaviour Exnem.Node.Impl

  require Logger

  @spec get(binary) :: {:ok, map} | {:error, String.t()}
  def get(endpoint) do
    url = "http://#{Exnem.node_url()}/#{endpoint}"

    Logger.debug("[Exnem.Node] GET #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.Parser.parse!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404 - Not Found"}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Logger.debug("[Exnem.Node] GET #{url} returned status #{code}: " <> body)
        {:error, "Expected Status 200, but received #{code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug("[Exnem.Node] GET #{url} returned an error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec post(binary, map) :: nil | true | false | list | float | integer | String.t | map | {:error, String.t()}
  def post(endpoint, %{} = params) do
    url = "http://#{Exnem.node_url()}/#{endpoint}"
    body = Poison.encode!(params)

    Logger.debug("[Exnem.Node] POST #{url}, params: #{inspect(params)}")

    case HTTPoison.post(url, body, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.Parser.parse!(body)

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Logger.debug("[Exnem.Node] POST #{url} returned status #{code}: " <> body)
        {:error, "Expected Status 200, but received #{code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug("[Exnem.Node] POST #{url} returned an error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec put(binary, map) :: nil | true | false | list | float | integer | String.t | map | {:error, String.t()}
  def put(endpoint, %{} = params) do
    url = "http://#{Exnem.node_url()}/#{endpoint}"
    body = Poison.encode!(params)

    Logger.debug("[Exnem.Node] PUT #{url}, params: #{inspect(params)}")

    case HTTPoison.put(url, body, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 202, body: body}} ->
        Poison.Parser.parse!(body)

      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        Logger.debug("[Exnem.Node] PUT #{url} returned status 404: " <> body)
        {:error, "404 - Not Found: " <> body}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Logger.debug("[Exnem.Node] PUT #{url} returned status #{code}: " <> body)
        {:error, "Expected Status 202, but received #{code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug("[Exnem.Node] PUT #{url} returned an error: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
