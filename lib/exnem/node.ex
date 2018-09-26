defmodule Exnem.Node do
  @moduledoc """
  NEM Node API.
  """

  @behaviour Exnem.Node.Impl

  @spec get(binary) :: {:ok, map} | {:error, String.t()}
  def get(endpoint) do
    impl().get(endpoint)
  end

  @spec post(binary, map) :: nil | true | false | list | float | integer | String.t | map | {:error, String.t()}
  def post(endpoint, %{} = params) do
    impl().post(endpoint, params)
  end

  @spec put(binary, map) :: nil | true | false | list | float | integer | String.t | map | {:error, String.t()}
  def put(endpoint, %{} = params) do
    impl().put(endpoint, params)
  end

  defp impl do
    Application.get_env(:exnem, :node_impl, Exnem.Node.Impl.DefaultImpl)
  end
end
