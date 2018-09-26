defmodule Exnem.Node.Impl do
  @moduledoc false

  @callback get(binary) :: {:ok, map} | {:error, String.t()}
  @callback post(binary, map) :: nil | true | false | list | float | integer | String.t | map | {:error, String.t()}
  @callback put(binary, map) :: nil | true | false | list | float | integer | String.t | map | {:error, String.t()}
end
