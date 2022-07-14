defmodule ServerWeb.PageController do
  use ServerWeb, :controller

  def index(conn, _params) do
    conn
      |> send_resp(404, "Not Found")
  end

  def cheat(conn, params) do
    if params["roomId"] !== nil do
      if :ets.member(:rooms, params["roomId"]) do
        conn |> send_resp(200, :ets.lookup_element(:rooms, params["roomId"], 4))
      else
        conn |> send_resp(404, "Room does not exist")
      end
    else
      conn |> send_resp(200, Agent.get(WordAgent, fn value -> value end))
    end
  end
end
