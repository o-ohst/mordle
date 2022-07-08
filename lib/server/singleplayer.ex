defmodule Server.Singleplayer do
  use GenServer
  @name __MODULE__

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    Agent.start_link(fn -> Helpers.randomWord() end, name: WordAgent)
    Task.start(fn ->
        :timer.sleep(86400000) #1 day
        Agent.update(WordAgent, fn _ -> Helpers.randomWord() end)
    end)
  end

  def handle_call({:guess, data}, _ref, state) do
    {guess} = data
    correctLetters = Agent.get(WordAgent, fn value -> value end) |> String.graphemes()
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
    {:reply, %{result: result}, state}
  end

  def handle_call({:end, data}, _ref, state) do
    {playerId, scores} = data ##TODO put in database
    {:noreply, state}
  end

  def guess(guess) do
    res = GenServer.call(@name, {:guess, {guess}})
    {:ok, res}
  end

  def ends(playerId, scores) do
    GenServer.call(@name, {:end, {playerId, scores}})
    {:ok, nil}
  end

end
