defmodule Server.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friends" do
    field :user1, :integer
    field :user2, :integer
    timestamps()
    belongs_to :user, Server.User
  end

  @doc false
  def changeset(friend, attrs) do
    friend
    |> cast(attrs, [])
    |> validate_required([])
  end
end
