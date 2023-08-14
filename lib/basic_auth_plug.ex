defmodule WatcherWeb.BasicAuthPlug do
  @moduledoc """
  Used to protect the metrics dashboard from being available
  to unauthorized parties.
  """

  def basic_auth(conn, opts \\ []) do
    should_bypass_auth = Keyword.get(opts, :should_bypass, false)

    if should_bypass_auth do
      conn
    else
      username = credentials(:username)
      password = credentials(:password)
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    end
  end

  def credentials(key) do
    Application.get_env(:watcher, :basic_auth)[key]
  end
end
