defmodule ServerWeb.ApiController do
  use ServerWeb, :controller
  alias Server.{User, Result, Friend, Repo}, warn: false
  import Ecto.Query, only: [from: 2]

  ##multiplayer

  def register(conn, _params) do
    conn |> json(%{playerId: Helpers.randomPlayerId()})
  end

  def createRoom(conn, _params) do
    {:ok, %{roomId: roomId}} = Server.Datastore.createRoom()
    conn
      |> json(%{roomId: roomId})
  end

  ##singleplayer

  def guess(conn, params) do
    {:ok, %{result: score}} = Server.Singleplayer.guess(params["guess"])
    conn
    |> json(%{score: score})
  end

  def endGame(conn, params) do
    if Server.Guardian.Plug.authenticated?(conn) do
      user = conn |> Server.Guardian.Plug.current_resource()
      if Repo.exists?(from r in Result, where: r.userId == ^user and r.date == ^Date.utc_today()) do
        conn |> send_resp(400, "Result exists for today")
      else
        Repo.insert(%Result{scores: params["scores"],
          numGuesses: length(params["scores"]),
          timeTaken: params["timeTaken"],
          userId: user,
          date: Date.utc_today()})
        word = Server.Singleplayer.getWord()
        conn |> json(%{word: word})
      end
    else
      word = Server.Singleplayer.getWord()
      conn |> json(%{word: word})
    end
  end

  #user

  def userStats(conn, _params) do
    user = conn |> Server.Guardian.Plug.current_resource()
    results = Repo.all(from r in Result,
      where: r.userId == ^user and r.date > ^Date.add(Date.utc_today(), -8),
      select: {r.numGuesses, r.timeTaken, r.date})
      |> Enum.map(
        fn t -> %{numGuesses: elem(t, 0), timeTaken: elem(t, 1), date: elem(t, 2)} end )
    conn
      |> json(%{results: results})
  end

  def playedToday(conn, _params) do
    user = conn |> Server.Guardian.Plug.current_resource()
    played = Repo.exists?(from r in Result, where: r.userId == ^user and r.date == ^Date.utc_today())
    conn |> json(%{played: played})
  end

  @spec leaderboard(Plug.Conn.t(), any) :: Plug.Conn.t()
  def leaderboard(conn, _params) do #{leaderboard: [ name, username, numGuesses], … }
    user = conn |> Server.Guardian.Plug.current_resource()

    friendIds = Repo.all(from f in Friend, where: f.userId == ^user, select: f.friendId)
    data = Repo.all(from r in Result,
      join: u in User,
      on: r.userId == u.id,
      where: r.userId in ^friendIds or r.userId == ^user,
      select: {u.username, u.name, r.numGuesses, r.timeTaken},
      order_by: [asc: r.numGuesses])
      |> Enum.map(fn t -> %{username: elem(t,0), name: elem(t,1), numGuesses: elem(t,2), timeTaken: elem(t,3)} end)
    conn |> json(%{data: data})
  end

  def friends(conn, _params) do
    user = conn |> Server.Guardian.Plug.current_resource()
    friends = Repo.all(from f in Friend, where: f.userId == ^user, select: f.friendId)
      |> Enum.map(fn friendId -> Repo.one(from u in User, where: u.id == ^friendId, select: {u.username, u.name}) end)
      |> Enum.map(fn t -> %{username: elem(t, 0), name: elem(t, 1)} end)
    conn |> json(%{friends: friends})
  end

  def addFriend(conn, %{"username" => username}) do
    user = conn |> Server.Guardian.Plug.current_resource()
    case Repo.get_by(User, username: username) do
      nil ->
        conn |> send_resp(400, "No such user")
      friend ->
        if Repo.exists?(from f in Friend, where: f.userId == ^user and f.friendId == ^friend.id) do
          conn |> send_resp(400, "Friend exists")
        else
          Repo.insert(%Friend{userId: user, friendId: friend.id})
          Repo.insert(%Friend{userId: friend.id, friendId: user})
          conn |> send_resp(200, "Success")
        end
    end
  end

  def unfriend(conn, %{"username" => username}) do
    user = conn |> Server.Guardian.Plug.current_resource()
    case Repo.get_by(User, username: username) do
      nil ->
        conn |> send_resp(400, "No such user")
      friend ->
        if Repo.exists?(from f in Friend, where: f.userId == ^user and f.friendId == ^friend.id) do
          Repo.delete_all(from f in Friend, where: (f.userId == ^user and f.friendId == ^friend.id) or (f.userId == ^friend.id and f.friendId == ^user))
          conn |> send_resp(200, "Success")
        else
          conn |> send_resp(400, "No such friend")
        end
    end
  end

end
