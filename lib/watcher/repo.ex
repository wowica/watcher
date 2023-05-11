defmodule Watcher.Repo do
  use Ecto.Repo,
    otp_app: :watcher,
    adapter: Ecto.Adapters.Postgres
end
