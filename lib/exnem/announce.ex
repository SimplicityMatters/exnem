defmodule Exnem.Announce do
  require Logger

  import Exnem.Config, only: [block_duration: 0]

  def announce(%{payload: payload, hash: _hash}) do
    case Exnem.Node.put("transaction", %{payload: payload}) do
      %{"message" => <<"packet 9"::binary, _tail::binary>>} ->
        Logger.debug("[Catapult] Complete transaction announced successfully")
        :ok

      a ->
        Logger.warn("[Catapult] Announcing complete transaction failed: #{inspect(a)}")
        a
    end
  end

  def sync_announce(%{payload: payload, hash: hash}) do
    timeout = block_duration() * 3
    task = Task.async(Exnem.SyncAnnounceTask, :run, [payload, hash])

    case Task.yield(task, timeout * 1000) || Task.shutdown(task, 2000) do
      {:ok, reply} ->
        reply

      {:exit, reason} ->
        {:error, reason}

      nil ->
        :timeout
    end
  end
end

defmodule Exnem.SyncAnnounceTask do
  use Task

  import Exnem.Announce, only: [announce: 1]
  import Exnem.Transaction, only: [signer_from_payload: 1]
  import Exnem.Crypto.KeyPair, only: [public_key_to_address: 2]

  def run(payload, hash) do
    signer = signer_from_payload(payload)

    state = %{
      signer: signer,
      signer_address: public_key_to_address(signer, Exnem.Config.network_type()),
      payload: payload,
      hash: hash
    }

    with {:ok, observer} <- Exnem.Observer.start_link(state.signer_address, self()) do
      state = Map.put(state, :observer, observer)

      receive_loop(state)
    end
  end

  def handle_info("observerReady", state) do
    case announce(%{payload: state.payload, hash: state.hash}) do
      :ok ->
        {:continue, state}

      {:error, reason} ->
        {:done, {:error, reason}}
    end
  end

  def handle_info({"confirmedAdded", %{meta: %{hash: hash}} = confirmation}, state) do
    if hash == state.hash do
      {:done, {:ok, confirmation}}
    else
      {:continue, state}
    end
  end

  def handle_info({"error", %{meta: %{hash: hash}, meaning: meaning}}, state) do
    if hash == state.hash do
      {:done, {:error, meaning}}
    else
      {:continue, state}
    end
  end

  def handle_info(_msg, state) do
    {:continue, state}
  end

  defp receive_loop(state) do
    receive do
      :shutdown ->
        Exnem.Observer.stop(state.observer)
        :shutdown

      msg ->
        case handle_info(msg, state) do
          {:continue, updated_state} ->
            receive_loop(updated_state)

          {:done, result} ->
            Exnem.Observer.stop(state.observer)
            result
        end
    end
  end
end
