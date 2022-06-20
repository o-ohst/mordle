defmodule Helpers do
  def randomRoomId() do
    word = Randomizer.words!(2) |> String.replace(" ", "-")
    if :ets.member(:rooms, word) do
      randomRoomId()
    else word
    end
  end

  def randomPlayerId() do
    id = Enum.random(0..10000)
    if :ets.member(:players, id) do
      randomPlayerId()
    else id
    end
  end

  def randomWord() do
    Randomizer.words!(1)
  end
end
