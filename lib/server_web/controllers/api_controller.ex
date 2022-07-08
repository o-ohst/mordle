defmodule ServerWeb.ApiController do
  use ServerWeb, :controller

  def register(conn, _params) do
    conn |> json(%{playerId: Helpers.randomPlayerId()})
  end

  def createRoom(conn, _params) do
    {:ok, %{roomId: roomId}} = Server.Datastore.createRoom()
    conn
      |> json(%{roomId: roomId})
  end

  def guess(conn, params) do
    {:ok, %{result: score}} = Server.Singleplayer.guess(params["guess"])
    conn
    |> json(%{score: score})
  end

  def ends(conn, params) do

  end

end
