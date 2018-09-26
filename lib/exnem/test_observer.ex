defmodule Exnem.TestObserver do
  use GenServer
  require Logger

  ##
  ## Client API
  ##

  def start_link(address, parent) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [address, parent])

    {:ok, pid}
  end

  def start(address, parent) do
    {:ok, pid} = GenServer.start(__MODULE__, [address, parent])

    {:ok, pid}
  end

  def stop(pid) do
    send(pid, :stop)
  end

  def init([address, parent]) do
    state = %{
      parent: parent,
      address: Exnem.normalize_address(address),
      uid: nil,
      subscriptions: Map.new(),
      block: false,
      locks: %{}
    }

    {:ok, state}
  end

  def ready(pid) do
    GenServer.call(pid, :ready)
  end

  ##
  ## Server API
  ##

  def handle_info(:ready, state) do
    new_state = %{state | uid: generate_fake_uid()}
    notify_parent("observerReady", new_state)

    {:noreply, new_state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, _ws_state) do
    Logger.warn("[Observer] Socket Terminating: #{inspect(reason)}\n")
  end

  defp notify_parent(msg, state) do
    send(state.parent, msg)
  end

  defp generate_fake_uid() do
    :rand.uniform(100_000_000)
    |> to_string
    |> Base.encode32(padding: false)
  end
end
