defmodule Server.Repo.Migrations.CreateFriendsTable do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :userId, references(:users), null: false
      add :friendId, references(:users), null: false
      timestamps()
    end
    create unique_index(:friends, [:userId, :friendId], name: :friendship_index)
  end
end
