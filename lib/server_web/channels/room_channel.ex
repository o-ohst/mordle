defmodule ServerWeb.RoomChannel do
  use ServerWeb, :channel
  alias ServerWeb.Presence

  # def join("room:new", _payload, socket) do
  #   Server.Datastore.createRoom()
  #   {:ok, :ets.lookup(:rooms, :ets.first(:rooms)) |> List.first |> (fn({n, a, f}) -> %{room_id: n, players: a |> Tuple.to_list(), answer: f} end).(),socket}
  # end

  @impl true
  def join("room:" <> roomId, payload, socket) do
    {status, _} = Server.Datastore.joinRoom(roomId, socket.assigns.playerId, payload[:playerName])
    send(self(), :after_join)
    if status == :ok do
      {:ok,  assign(socket, :playerName, payload["playerName"])}
    else
      {:error, %{reason: "invalid room id"}}
    end
    # :ets.insert(:rooms, {room_id, {0,1}, "hello"})
    # {:ok, :ets.lookup(:rooms, room_id) |> List.first |> (fn({n, a, f}) -> %{room_id: n, players: a |> Tuple.to_list(), answer: f} end).(),socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.playerId, %{})
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("joined", _payload, socket) do
    "room:" <> roomId = socket.topic
    {:ok, data} = Server.Datastore.getRoom(roomId)
    broadcast(socket, "joined", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName} |> Map.put(:data, data))
    # %{roomId: r, players: p, state: s} = Server.Datastore.getRoom(roomId)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_guess", payload, socket) do
    broadcast(socket, "new_guess",  %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName} |> Map.merge(payload) )
    # IO.inspect(:ets.lookup(:rooms, :ets.first(:rooms)))
    {:noreply, socket}
  end

  @impl true
  def handle_in("ready", _payload, socket) do
    broadcast(socket, "ready", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName})
    # IO.inspect(:ets.lookup(:rooms, :ets.first(:rooms)))
    {:noreply, socket}
  end


  # Phoenix.Channel.intercept(["presence_diff"])

  # @impl true
  # def handle_out("presence_diff", payload, socket) do
  #   %{:joins => joins, :leaves => leaves} = payload
  #   IO.write("presence diff ")
  #   IO.inspect(joins)
  #   "room:" <> roomId = socket.topic
  #   for _z <- joins, do: Server.Datastore.updateCounter(roomId, true)
  #   for _z <- leaves, do: Server.Datastore.updateCounter(roomId, false)
  # end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
