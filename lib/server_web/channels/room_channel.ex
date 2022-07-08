defmodule ServerWeb.RoomChannel do
  use ServerWeb, :channel
  alias ServerWeb.Presence

  # def join("room:new", _payload, socket) do
  #   Server.Datastore.createRoom()
  #   {:ok, :ets.lookup(:rooms, :ets.first(:rooms)) |> List.first |> (fn({n, a, f}) -> %{room_id: n, players: a |> Tuple.to_list(), answer: f} end).(),socket}
  # end

  @impl true
  def join("room:" <> roomId, payload, socket) do
    {status, _} = Server.Datastore.joinRoom(roomId, socket.assigns.playerId, payload["playerName"])
    send(self(), :after_join)
    IO.inspect(payload["playerName"])
    if status == :ok do
      {:ok, assign(socket, :playerName, payload["playerName"])}
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
    {:noreply, socket}
  end

  @impl true
  def handle_in("ready", payload, socket) do
    "room:" <> roomId = socket.topic
    broadcast(socket, "ready", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName})
    {:ok, %{allReady: allReady}} = Server.Datastore.ready(socket.assigns.playerId, roomId)
    {:ok, roomData} = Server.Datastore.getRoom(roomId)
    if allReady && length(roomData[:players]) >= 2 do
      broadcast(socket, "start_game", payload)
      Task.start(fn ->
        :timer.sleep(3000)
        broadcast(socket, "start_round", %{})
      end)
    end
    {:noreply, socket}
  end

  defp endRound(roomId, socket) do
    {:ok, data} = Server.Datastore.endRound(roomId)
    if !data[:gameOver] do
      Task.start(fn ->
        :timer.sleep(5000)
        broadcast(socket, "start_round", %{})
      end)
    else
      Server.Datastore.endGame(roomId)
    end
    broadcast(socket, "end_round", data)

  end

  @impl true
  def handle_in("new_guess", payload, socket) do
    # IO.inspect(:ets.lookup(:rooms, :ets.first(:rooms)))
    "room:" <> roomId = socket.topic

    {status, %{result: result}} = Server.Datastore.evaluateGuess(roomId, socket.assigns.playerId, payload["guess"])

    if status === :ok do
      {:ok, pData} = Server.Datastore.getPlayer(socket.assigns.playerId)

      row = pData[:row]
      broadcast(socket, "new_guess",  %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName, row: row})

      if result === "22222" do #correct
        {:ok, %{allFinished: allFinished}} = Server.Datastore.finish(socket.assigns.playerId, roomId, true)
        broadcast(socket, "finish", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName, result: "correct"})
        if allFinished, do: endRound(roomId, socket)
        {:reply, {:ok, %{result: result, allFinished: allFinished}}, socket}
      else
        if pData[:row] >= 6 do #run out of guesses
        {:ok, %{allFinished: allFinished}} = Server.Datastore.finish(socket.assigns.playerId, roomId, false)
        broadcast(socket, "finish", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName, result: "wrong"})
        if allFinished, do: endRound(roomId, socket)
        {:reply, {:ok, %{result: result, allFinished: allFinished, row: row}}, socket}
        else
          {:reply, {:ok, %{result: result, allFinished: false, row: row}}, socket}
        end
      end
    else
      {:noreply, socket}
    end
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
  # defp authorized?(_payload) do
  #   true
  # end
end
