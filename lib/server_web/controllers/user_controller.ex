defmodule ServerWeb.UserController do
  use ServerWeb, :controller

  def signUp(conn, params) do
    changeset = Server.User.changeset(%Server.User{}, %{username: params["username"], password: params["password"], name: params["name"]})
    case Server.Repo.insert(changeset) do
      {:ok, _user} ->
        conn |> send_resp(200, "Success")
      {:error, _changeset} ->
        conn |> send_resp(400, "Bad Request")
    end
  end

  def login(conn, params) do
    if Auth.verifyPassword?(params["password"], Server.Repo.get_by(Server.User, username: params["username"]).password) do
      conn |> send_resp(200, "Success")
    else
      conn |> send_resp(401, "Unauthorized")
    end
  end
end
