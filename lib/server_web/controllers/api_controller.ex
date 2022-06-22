defmodule ServerWeb.ApiController do
  use ServerWeb, :controller

  def register(conn, _params) do
    conn |> json(%{playerId: Helpers.randomPlayerId()})
  end

  def createRoom(conn, params) do #params[playerId] is nil
    IO.inspect(params)
    {:ok, %{roomId: roomId}} = Server.Datastore.createRoom()
    conn
      |> json(%{roomId: roomId})
  end

end
