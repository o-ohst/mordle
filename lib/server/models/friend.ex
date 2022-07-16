defmodule Server.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friends" do
    field :userId, :integer
    field :friendId, :integer
    timestamps()
    belongs_to :user, Server.User
  end

  @doc false
  def changeset(friend, attrs) do
    friend
    |> cast(attrs, [])
    |> validate_required([:userId, :friendId])
    |> unique_constraint([:userId, :friendId])
  end
end
