defmodule Server.Repo.Migrations.CreateResultsTable do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :scores, {:array, :string}, null: false
      add :numGuesses, :integer, null: false
      add :date, :date, null: false
      add :timeTaken, :integer, null: false
      add :userId, references(:users), null: false
      timestamps()
    end
  end
end
