defmodule Server.Datastore do
  use GenServer

  # rooms (set)
  #   {id, players:{}, started, word, round}
  # players (set)
  #   {id, roomId, state, row, score}
  # guesses (bag)
  #   {guess, playerId, roomId, row, result}
  ## presence (set)
  ##   {roomId, counter}


  @name __MODULE__

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    :ets.new(:rooms, [:set, :named_table, :public])
    :ets.new(:players, [:set, :named_table])
    :ets.new(:guesses, [:bag, :named_table])
    {:ok, words} = File.read(Path.join([Application.app_dir(:server), "priv/data/words.txt"]))
    word_list = words |> String.split("\n", trim: true) |> Enum.map(fn x -> {x} end)
    :ets.new(:allowed, [:set, :named_table])
    :ets.insert(:allowed, word_list)
    # :ets.new(:presence, [:set, :named_table, :public])
    {:ok, "Done"}
  end

  def handle_call({:getRoom, roomId}, _ref, state) do
    [{id, players, started, _word, round}] = :ets.lookup(:rooms, roomId)
    res = %{roomId: id, players: players |> Enum.map(fn {a, b} -> %{playerId: a, playerName: b, state: :ets.lookup_element(:players, a, 3)} end), started: started, round: round}
    {:reply, res, state}
  end

  def handle_call({:createRoom, data}, _ref, state) do
    :ets.insert(:rooms, data)
    IO.inspect(data)
    {:reply, :ok, state}
  end

  def handle_call({:joinRoom, data}, _ref, state) do
    {roomId, playerId, playerName} = data
    :ets.update_element(:rooms, roomId, {2, [ {playerId, playerName} | :ets.lookup_element(:rooms, roomId, 2) ]})
    :ets.insert(:players, {playerId, roomId, "joined", 0, 0})
    {:reply, :ok, state}
  end

  def handle_call({:deleteRoom, data}, _ref, state) do #remove all data from room players
    {roomId} = data
    :ets.delete(:rooms, roomId)
    # :ets.delete(:presence, roomId)
    players = :ets.match(:rooms, {roomId, :"$1", :_, :_, :_})
    for p <- players |> Enum.flat_map(&Function.identity/1) do
      :ets.delete(:players, p)
      :ets.match_delete(:guesses, {:_, p, :_, :_, :_})
    end
    {:reply, :ok, state}
  end

  def handle_call({:getPlayer, playerId}, _ref, state) do
    [{id, roomId, pState, row, score}] = :ets.lookup(:players, playerId)
    res = %{playerId: id, roomId: roomId, state: pState, row: row, score: score}
    {:reply, res, state}
  end

  def handle_call({:guess, data}, _ref, state) do
    {roomId, playerId, guess} = data
    correctLetters = :ets.lookup_element(:rooms, roomId, 4) |> String.graphemes()
    guessLetters = guess |> String.graphemes()
    result =
      Enum.zip(correctLetters, guessLetters)
      |> Enum.map(fn {a, b} ->
        if a === b do
          2
        else
          if Enum.member?(correctLetters, b), do: 1, else: 0
        end
      end)
      |> Enum.join()
    row = :ets.lookup_element(:players, playerId, 4) + 1
    :ets.insert(:guesses, {guess, roomId, playerId, row, result})
    :ets.update_counter(:players, playerId, {4, 1})
    {:reply, %{result: result}, state}
  end

  def handle_call({:ready, data}, _ref, state) do
    {playerId, roomId} = data
    :ets.update_element(:players, playerId, {3, "ready"})
    allReady = :ets.match(:players, {:_, roomId, :"$1", :_, :_})
      |> Enum.flat_map(&Function.identity/1)
      |> Enum.all?(fn s -> s === "ready" end)
    {:reply, %{allReady: allReady}, state}
  end

  def handle_call({:finish, data}, _ref, state) do
    {playerId, roomId, correct} = data
    numPlayers = :ets.lookup_element(:rooms, roomId, 2) |> length()
    numCorrectSoFar = :ets.match(:players, {:"$1", roomId, "correct", :_, :_}) |> length()
    score = if correct, do: numPlayers - numCorrectSoFar, else: 0

    :ets.update_element(:players, playerId, {5, score + :ets.lookup_element(:players, playerId, 5)})
    :ets.update_element(:players, playerId, {3, (if correct, do: "correct", else: "wrong")})
    allFinished = :ets.match(:players, {:_, roomId, :"$1", :_, :_})
      |> Enum.flat_map(&Function.identity/1)
      |> Enum.reduce(true, fn x, acc -> (x === "correct" || x === "wrong") && acc end)

    {:reply, %{allFinished: allFinished}, state}
  end

  def handle_call({:startRound, {roomId}}, _ref, state) do
    :ets.update_element(:rooms, roomId, {3, true})
    :ets.update_counter(:rooms, roomId, {5, 1})
    :ets.update_element(:rooms, roomId, {4, Helpers.randomWord()})
    :ets.match(:players, {:"$1", roomId, :_, :_, :_})
    |> Enum.flat_map(&Function.identity/1)
    |> Enum.each(fn x ->
      :ets.update_element(:players, x, {3, "ready"})
      :ets.update_element(:players, x, {4, 0})
    end)
    IO.inspect(:ets.lookup(:rooms, roomId))
    {:reply, :ok, state}
  end

  def handle_call({:endRound, {roomId}}, _ref, state) do
    :ets.update_element(:rooms, roomId, {3, false})
    [{_, _, _, word, round}] = :ets.lookup(:rooms, roomId)
    gameOver = round === 3

    :ets.match_delete(:guesses, {:_, :_, roomId, :_, :_})

    scores = :ets.match(:players, {:"$1", roomId, :_, :_, :_})
      |> Enum.flat_map(&Function.identity/1)
      |> Enum.reduce(%{}, fn x, acc -> acc |> Map.put(x, :ets.lookup_element(:players, x, 5)) end)

    {:reply, %{gameOver: gameOver, scores: scores, word: word}, state}
  end





  ### main client helpers

  def getRoom(roomId) do
    res = GenServer.call(@name, {:getRoom, roomId})
    {:ok, res}
  end

  def createRoom() do
    roomData = {roomId, [], _started, _word, _round} = {Helpers.randomRoomId(), [], false, "", 0}
    GenServer.call(@name, {:createRoom, roomData})
    {:ok, %{roomId: roomId}}
  end

  def joinRoom(roomId, playerId, playerName) do
    if :ets.member(:rooms, roomId) do
      GenServer.call(@name, {:joinRoom, {roomId, playerId, playerName}})
      {:ok, nil}
    else
      {:error, %{reason: "invalid room id"}}
    end
  end

  def getPlayer(playerId) do
    res = GenServer.call(@name, {:getPlayer, playerId})
    {:ok, res}
  end

  def ready(playerId, roomId) do
    res = GenServer.call(@name, {:ready, {playerId, roomId}})
    {:ok, res}
  end

  def evaluateGuess(roomId, playerId, guess) do
    res = GenServer.call(@name, {:guess, {roomId, playerId, guess}})
    {:ok, res}
  end

  def finish(playerId, roomId, correct) do
    res = GenServer.call(@name, {:finish, {playerId, roomId, correct}})
    {:ok, res}
  end

  def startRound(roomId) do
    res = GenServer.call(@name, {:startRound, {roomId}})
    {:ok, res}
  end

  def endRound(roomId) do
    res = GenServer.call(@name, {:endRound, {roomId}})
    {:ok, res}
  end

  def endGame(roomId) do
    GenServer.call(@name, {:deleteRoom, {roomId}})
    {:ok, nil}
  end
end
