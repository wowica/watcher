defmodule Watcher.Repo.Migrations.CreateTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers) do
      add :receiving_address, :string
      add :amount, :bigint
      add :timestamp, :bigint

      timestamps()
    end
  end
end
