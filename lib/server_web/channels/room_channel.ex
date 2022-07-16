defmodule ServerWeb.RoomChannel do
  use ServerWeb, :channel

  @impl true
  def join("room:" <> roomId, payload, socket) do
    {status, _} = Server.Datastore.joinRoom(roomId, socket.assigns.playerId, payload["playerName"])
    if status == :ok do
      send(self(), :joined)
      {:ok, assign(socket, :playerName, payload["playerName"])}
    else
      {:error, %{reason: "invalid room id"}}
    end
  end

  @impl true
  def handle_info(:joined, socket) do
    "room:" <> roomId = socket.topic
    {:ok, data} = Server.Datastore.getRoom(roomId)
    broadcast(socket, "joined", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName} |> Map.put(:data, data))
    {:noreply, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("ready", payload, socket) do
    "room:" <> roomId = socket.topic
    broadcast(socket, "ready", %{playerId: socket.assigns.playerId, playerName: socket.assigns.playerName})
    {:ok, %{allReady: allReady}} = Server.Datastore.ready(socket.assigns.playerId, roomId)
    {:ok, roomData} = Server.Datastore.getRoom(roomId)
    if allReady && length(roomData[:players]) >= 2 do
      IO.puts("Game start")
      broadcast(socket, "start_game", payload)
      Task.start(fn ->
        :timer.sleep(3000)
        startRound(socket)
      end)
    end
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_guess", payload, socket) do
    "room:" <> roomId = socket.topic

    {:ok, %{result: result}} = Server.Datastore.evaluateGuess(roomId, socket.assigns.playerId, payload["guess"])

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
  end

  defp startRound(socket) do
    IO.puts("Round start")
    "room:" <> roomId = socket.topic
    Server.Datastore.startRound(roomId)
    {:ok, %{roomId: _, players: _, started: _, round: round} } = Server.Datastore.getRoom(roomId);
    Task.start(fn ->
        :timer.sleep(30000) #180000
        timerEndRound(roomId, socket, round)
      end)
    broadcast(socket, "start_round", %{})
  end

  defp endRound(roomId, socket) do
    IO.puts("Round end")
    {:ok, data} = Server.Datastore.endRound(roomId)
    if !data[:gameOver] do
      Task.start(fn ->
        :timer.sleep(5000)
        startRound(socket)
      end)
    else
      IO.puts("Game end")
      Server.Datastore.endGame(roomId)
    end
    broadcast(socket, "end_round", data)
  end

  defp timerEndRound(roomId, socket, roundToEnd) do
    if :ets.member(:rooms, roomId) do
      {:ok, %{roomId: _, players: _, started: _, round: round} } = Server.Datastore.getRoom(roomId);
      if roundToEnd === round do
        IO.write("Timer: ")
        endRound(roomId, socket)
      end
    end
  end
end
