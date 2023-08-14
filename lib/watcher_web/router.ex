defmodule WatcherWeb.Router do
  use WatcherWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WatcherWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :private_metrics do
    import WatcherWeb.BasicAuthPlug
    plug :basic_auth, should_bypass: Mix.env() in [:dev, :test]
  end

  scope "/", WatcherWeb do
    pipe_through :browser

    live "/", DashboardLive.Index, :index
  end

  scope "/metrics" do
    import Phoenix.LiveDashboard.Router

    pipe_through [:browser, :private_metrics]

    live_dashboard "/dashboard", metrics: WatcherWeb.Telemetry
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:watcher, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
