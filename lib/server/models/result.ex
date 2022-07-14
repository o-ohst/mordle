defmodule Server.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :scores, {:array, :string}
    field :numGuesses, :integer
    field :date, :date
    field :timeTaken, :integer
    field :userId, :integer
    timestamps()
    belongs_to :user, Server.User
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [])
    |> validate_required([])
  end
end
