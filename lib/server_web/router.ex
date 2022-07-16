defmodule ServerWeb.Router do
  use ServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ServerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  pipeline :maybe_auth do
    plug Guardian.Plug.Pipeline, module: Server.Guardian,
                             error_handler: Server.ErrorHandlers.JSON
    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end


  #page routes
  scope "/", ServerWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/shawn-cheat", PageController, :cheat
  end

  #api routes
  scope "/api", ServerWeb do
    pipe_through [:api, :maybe_auth]

    get "/register", ApiController, :register
    get "/create-room", ApiController, :createRoom
    post "/guess", ApiController, :guess
  end

  #api routes
  scope "/api", ServerWeb do
    pipe_through [:api, :maybe_auth]

    post "/signup", AuthController, :signup
    post "/login", AuthController, :login
  end

  #protected api routes
  scope "/api", ServerWeb do
    pipe_through [:api, :maybe_auth, :ensure_auth]

    post "/logout", AuthController, :logout
    get "/user-stats", ApiController, :userStats
    get "/friends", ApiController, :friends
    post "/add-friend", ApiController, :addFriend
    post "/unfriend", ApiController, :unfriend
    get "/leaderboard", ApiController, :leaderboard
    post "/end-game", ApiController, :endGame
  end

  #logged in only routes
  # scope "/api", ServerWeb do
  #   pipe_through: [:api, :ensure_auth]
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ServerWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
