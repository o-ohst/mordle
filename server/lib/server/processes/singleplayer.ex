defmodule Server.Singleplayer do
  use GenServer
  @name __MODULE__

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    Agent.start_link(fn -> Helpers.randomWord() end, name: WordAgent)
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

  def newWord() do
    word = Helpers.randomWord()
    Agent.update(WordAgent, fn _ -> word end)
    IO.write("New singleplayer word: ")
    IO.inspect(word)
  end

  def guess(guess) do
    res = GenServer.call(@name, {:guess, {guess}})
    {:ok, res}
  end

  def getWord() do
    Agent.get(WordAgent, fn w -> w end)
  end

end
