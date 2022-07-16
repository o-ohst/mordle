defmodule ServerWeb.UserController do
  use ServerWeb, :controller

  def createUser(username, password, name) do
    changeset = Server.User.changeset(%Server.User{}, %{username: username, password: password, name: name})
    Server.Repo.insert(changeset)
  end

  def authenticate(username, password) do
    case Server.Repo.get_by(Server.User, username: username) do
      nil ->
        {:error, "Invalid credentials"}
      user ->
        if Auth.verifyPassword?(password, user.password) do
          {:ok, user}
        else
          {:error, "Invalid credentials"}
        end
    end
  end

end
