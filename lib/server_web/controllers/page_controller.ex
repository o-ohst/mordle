defmodule ServerWeb.PageController do
  use ServerWeb, :controller

  def index(conn, _params) do

    text(conn |> Plug.Conn.put_status(502), "502 Bad Gateway")
  end

  def cheat(conn, params) do
    if params["roomId"] !== nil do
      if :ets.member(:rooms, params["roomId"]) do
        text(conn, :ets.lookup_element(:rooms, params["roomId"], 4))
      else
        text(conn |> Plug.Conn.put_status(404), "Room does not exist")
      end
    else
      text(conn |> Plug.Conn.put_status(404), "No roomId provided")
    end
  end
end
