defmodule Server.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password, :string
    field :name, :string
    timestamps()
    has_many :result, Server.Result
    has_many :friend, Server.Friend
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :name])
    |> validate_required([:username, :password, :name])
    |> unique_constraint(:username)
    |> hashPassword()
  end

  defp hashPassword(%Ecto.Changeset{valid?: true, changes:
    %{password: password}} = changeset) do
    change(changeset, password: Auth.hashPassword(password))
  end

  defp hashPassword(changeset), do: changeset
end
