defmodule Exnem.Config do
  def network_type() do
    Application.fetch_env!(:exnem, :network_type)
  end

  def block_duration() do
    Application.fetch_env!(:exnem, :block_duration)
  end
end
