defmodule ServerWeb.AuthController do
  use ServerWeb, :controller
  import Ecto.Query, only: [from: 2]

  def signup(conn, %{"username" => username, "password" => password, "name" => name}) do
    if Server.Guardian.Plug.authenticated?(conn) do
      conn |> send_resp(400, "Already logged in")
    else
      if Server.Repo.exists?(from u in Server.User, where: u.username == ^username) do
        conn |> send_resp(400, "User exists")
      else
        case ServerWeb.UserController.createUser(username, password, name) do
          {:ok, _user} ->
            conn |> send_resp(200, "Success")
          {:error, _changeset} ->
            conn |> send_resp(400, "Bad request")
        end
      end
    end
  end

  def signup(conn, _params) do
    conn |> send_resp(400, "Bad params")
  end

  def login(conn, %{"username" => username, "password" => password}) do
    if Server.Guardian.Plug.authenticated?(conn) do
      conn |> send_resp(400, "Already logged in")
    else
      case ServerWeb.UserController.authenticate(username, password) do
        {:ok, user} ->
          conn
            |> Server.Guardian.Plug.sign_in(user)
            |> send_resp(200, "Success")
        {:error, reason} ->
          conn |> send_resp(401, reason)
      end
    end
  end

  def login(conn, _params) do
    conn |> send_resp(400, "Bad params")
  end

  def logout(conn, _params) do
    conn
      |> Server.Guardian.Plug.sign_out()
      |> send_resp(200, "Success")
  end
end
