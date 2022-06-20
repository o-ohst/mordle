defmodule Server.Datastore do
  use GenServer

  # rooms (set)
  #   {id, players:{}, word}
  # players (set)
  #   {id, roomId, state}
  # guesses (bag)
  #   {guess, playerId, roomId, row, result}
  ## presence (set)
  ##   {roomId, counter}


  @name __MODULE__

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    IO.puts("Creating ETS #{@name}")
    :ets.new(:rooms, [:set, :named_table, :public])
    :ets.new(:players, [:set, :named_table])
    :ets.new(:guesses, [:bag, :named_table])
    {:ok, allowed_words} = File.read(Path.join([Application.app_dir(:server), "priv/data/words.txt"]))
    allowed_words_list = allowed_words |> String.split("\n", trim: true) |> Enum.map(fn x -> {x} end)
    :ets.new(:allowed, [:set, :named_table])
    :ets.insert(:allowed, allowed_words_list)
    # :ets.new(:presence, [:set, :named_table, :public])
    IO.puts("initialized genserver ets")
    {:ok, "Done"}
  end

  def handle_call({:createRoom, data}, _ref, state) do
    :ets.insert(:rooms, data)
    IO.puts("ets inserted room")
    # :ets.insert(:presence, {data |> elem(1), 0})
    {:reply, :ok, state}
  end

  def handle_call({:joinRoom, data}, _ref, state) do
    {roomId, playerId} = data
    :ets.update_element(:rooms, roomId, {2, [ playerId | :ets.lookup_element(:rooms, roomId, 2) ]})
    IO.puts("ets joined room")
    {:reply, :ok, state}
  end

  def handle_call({:deleteRoom, data}, _ref, state) do #remove all data from room players
    {roomId} = data
    IO.write("removing room ")
    IO.puts(roomId)
    :ets.delete(:rooms, roomId)
    :ets.delete(:presence, roomId)
    players = :ets.match(:rooms, {'_', '$1', '_'})
    for p <- players do
      :ets.delete(:players, p)
      :ets.match_delete(:guesses, {'_', p, '_', '_', '_'})
    end
    {:reply, :ok, state}
  end

  ### main client helpers

  def createRoom(playerId) do
    roomData = {roomId, {playerId}, word} = {Helpers.randomRoomId(), {playerId}, Helpers.randomWord()}
    IO.write("createRoom ")
    IO.inspect(roomData)
    GenServer.call(@name, {:createRoom, roomData})
    {:ok, %{roomId: roomId}}
  end

  def joinRoom(roomId, playerId) do
    if :ets.member(:rooms, roomId) do
      GenServer.call(@name, {:joinRoom, {roomId, playerId}})
      {:ok, nil}
    else
      {:error, %{reason: "invalid room id"}}
    end
  end

  # def updateCounter(roomId, opt) do #true for inc, false for dec
  #   if (opt) do
  #     :ets.update_counter(:presence, roomId, {2, 1})
  #     IO.puts("presence +1")
  #     IO.write("current presence: ")
  #     IO.inspect(:ets.lookup_element(:presence, roomId, 2))
  #   else
  #     :ets.update_counter(:presence, roomId, {2, -1})
  #     IO.puts("presence -1")
  #     IO.write("current presence: ")
  #     IO.inspect(:ets.lookup_element(:presence, roomId, 2))
  #   end
  #   if (:ets.lookup_element(:presence, roomId, 2) === 0) do
  #     IO.write("current presence: ")
  #     IO.inspect(:ets.lookup_element(:presence, roomId, 2))
  #     GenServer.call(@name, {:deleteRoom, {roomId}})
  #   end
  # end
end
