defmodule Server.Repo.Migrations.CreateFriendsTable do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :user1, references(:users), null: false
      add :user2, :integer, null: false
      timestamps()
    end
  end
end
