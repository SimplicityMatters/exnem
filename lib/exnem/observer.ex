defmodule Exnem.Observer do
  use WebSockex
  require Logger

  @channels [
    "status",
    # "cosignature",
    "confirmedAdded",
    "unconfirmedAdded"
    # "unconfirmedRemoved",
    # "partialAdded",
    # "partialRemoved"
  ]

  ##
  ## Client API
  ##

  def start_link(address, parent) do
    init(:start_link, address, parent)
  end

  def start(address, parent) do
    init(:start, address, parent)
  end

  def stop(pid) do
    send(pid, :stop)
  end

  def init(start_type, address, parent) when start_type == :start or start_type == :start_link do
    state = %{
      parent: parent,
      address: Exnem.normalize_address(address),
      uid: nil,
      subscriptions: Map.new(),
      block: false,
      locks: %{}
    }

    url = "ws://#{Exnem.node_url()}/ws"

    apply(WebSockex, start_type, [url, __MODULE__, state])
  end

  ##
  ## Server API
  ##

  def handle_cast({:send, {_type, _msg} = frame}, ws_state) do
    {:reply, frame, ws_state}
  end

  def handle_frame({:text, msg}, ws_state) do
    msg = Poison.Parser.parse!(msg)

    case msg do
      %{"uid" => uid} ->
        handle_uid(uid, ws_state)

      %{"block" => _data} ->
        handle_block(msg, ws_state)

      # Lock transaction
      %{"transaction" => %{"type" => 16716}} ->
        handle_lock_transaction(msg, ws_state)

      # Other Transactions
      %{"transaction" => %{"type" => _}} ->
        handle_transaction(msg, ws_state)

      %{"parentHash" => _, "signature" => _, "signer" => _} ->
        handle_cosignature(msg, ws_state)

      %{"status" => _, "hash" => _, "deadline" => _} ->
        handle_status(msg, ws_state)

      %{"meta" => %{"channelName" => "unconfirmedRemoved", "hash" => _}} ->
        handle_unconfirmed_removed(msg, ws_state)

      _ ->
        Logger.warn("[Observer] Unknown message received: #{inspect(msg)}")
        {:ok, ws_state}
    end
  end

  def handle_frame({type, msg}, ws_state) do
    Logger.debug(
      "[Observer] #{ws_state.address} received Message Type: #{inspect(type)}, Message: #{
        inspect(msg)
      }"
    )

    {:ok, ws_state}
  end

  def handle_info(:stop, state) do
    {:close, state}
  end

  def handle_info(:keepalive, ws_state) do
    keepalive()

    {:reply, {:ping, ""}, ws_state}
  end

  def handle_info(input, ws_state) do
    Logger.debug("[Observer] Non-keepalive handle_info: #{inspect(input)}")
    {:ok, ws_state}
  end

  def terminate(_reason, _ws_state) do
    Logger.debug("[Observer] Terminating")
  end

  def handle_disconnect(_connection_status_map, ws_state) do
    Logger.debug("[Observer] Disconnect")
    {:ok, ws_state}
  end

  def handle_connect(_conn, ws_state) do
    Logger.debug("[Observer] Connected")
    {:ok, ws_state}
  end

  def handle_uid(uid, state) do
    Logger.debug("[Observer] Received uid #{uid}")

    new_state =
      case state.uid do
        nil ->
          new_state = observe_address(%{state | uid: uid})
          notify_parent("observerReady", new_state)
          keepalive()

          new_state

        _ ->
          %{state | uid: uid}
      end

    {:ok, new_state}
  end

  def handle_block(msg, state) do
    block = receive_block(msg)
    Logger.debug("[Observer] Received block, new chain height is #{block.block.height}")
    notify_parent({"block", block}, state)

    {:ok, state}
  end

  def handle_lock_transaction(
        %{"meta" => %{"channelName" => "unconfirmedAdded", "hash" => hash}} = msg,
        state
      ) do
    tx = parse_transaction(msg)
    Logger.debug("[Observer] Received Lock unconfirmedAdded for #{hash}")
    notify_parent({"unconfirmedLockAdded", tx}, state)

    {:ok, state}
  end

  def handle_lock_transaction(
        %{"meta" => %{"channelName" => "confirmedAdded", "hash" => _}} = msg,
        state
      ) do
    tx = parse_transaction(msg)
    notify_parent({"confirmedLockAdded", tx}, state)

    {:ok, state}
  end

  def handle_lock_transaction(msg, state) do
    Logger.warn("[Observer] Lock transaction was not unconfirmed/confirmed? #{inspect(msg)}")

    {:ok, state}
  end

  def handle_transaction(%{"meta" => %{"channelName" => channel, "hash" => hash}} = msg, state) do
    Logger.debug("[Observer] #{state.address} received #{channel} for transaction #{hash}")

    tx = parse_transaction(msg)
    notify_parent({channel, tx}, state)

    {:ok, state}
  end

  def handle_cosignature(%{"parentHash" => hash} = msg, state) do
    Logger.debug("[Observer] Received cosignature for transaction #{hash}")

    cosig = receive_cosignature_transaction(msg)
    notify_parent({"cosignature", cosig}, state)

    {:ok, state}
  end

  def handle_unconfirmed_removed(%{"meta" => %{"hash" => hash}} = msg, state) do
    Logger.debug("[Observer] Received unconfirmedRemoved for transaction #{hash}")

    removed = receive_unconfirmed_removed(msg)
    notify_parent({"unconfirmedRemoved", removed}, state)

    {:ok, state}
  end

  def handle_status(%{"status" => status, "hash" => hash, "deadline" => deadline}, state) do
    meaning = Exnem.StatusErrors.meaning(status)
    Logger.info("[Observer] Status #{status} for #{hash}: #{meaning}")

    err = %{
      meta: %{hash: hash},
      status: status,
      meaning: meaning,
      deadline: deadline
    }

    notify_parent({"error", err}, state)

    {:ok, state}
  end

  defp notify_parent(msg, state) do
    send(state.parent, msg)
  end

  defp keepalive do
    Process.send_after(self(), :keepalive, ping_period())
  end

  defp ping_period() do
    # two minutes
    2 * 60 * 1_000
  end

  defp parse_transaction(msg) do
    {:ok, tx} = Exnem.DTO.parse_transaction(msg)

    tx
  end

  defp receive_unconfirmed_removed(%{
         "meta" => %{"channelName" => "unconfirmedRemoved", "hash" => hash}
       }) do
    %{
      meta: %{hash: hash}
    }
  end

  defp receive_cosignature_transaction(%{
         "parentHash" => hash,
         "signature" => signature,
         "signer" => signer
       }) do
    %{
      meta: %{hash: hash},
      signature: signature,
      signer: signer
    }
  end

  defp receive_block(msg) do
    {:ok, block} = Exnem.DTO.BlockInfo.new(msg)

    block
  end

  defp observe_address(%{address: address} = state) do
    Logger.debug("[Observer] Observing address #{address} ...")

    @channels
    |> Enum.reduce(state, fn channel, state ->
      subscribe(address, channel, state)
    end)
  end

  defp subscribe(address, channel, state) do
    # Observer logs warnings double-attempts at subscribe/unsubscribe
    # because Catapult will terminate the websocket when you send duplicates
    case already_subscribed?(address, channel, state) do
      true ->
        Logger.warn("[Observer] Already subscribed to #{channel} for address #{address}")
        state

      false ->
        subscribe = "#{channel}/#{address}"
        payload = %{subscribe: subscribe, uid: state.uid}
        frame = make_frame(payload)
        new_state = add_subscription(state, address, channel)

        WebSockex.cast(self(), {:send, frame})

        new_state
    end
  end

  defp already_subscribed?(address, channel, state) do
    Map.has_key?(state.subscriptions, address) &&
      MapSet.member?(state.subscriptions[address], channel)
  end

  defp make_frame(payload) do
    {:text, Poison.encode!(payload)}
  end

  defp add_subscription(state, address, channel) do
    new_channels =
      state.subscriptions
      |> Map.get(address, MapSet.new())
      |> MapSet.put(channel)

    new_subscriptions =
      state.subscriptions
      |> Map.put(address, new_channels)

    %{state | subscriptions: new_subscriptions}
  end
end
