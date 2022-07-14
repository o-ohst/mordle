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
    
  end
end
