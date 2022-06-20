defmodule ServerWeb.PageController do
  use ServerWeb, :controller

  def index(conn, _params) do

    text(conn |> Plug.Conn.put_status(502), "502 Bad Gateway")
  end
end
