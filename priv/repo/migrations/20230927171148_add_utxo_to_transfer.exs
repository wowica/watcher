defmodule Watcher.Repo.Migrations.AddUtxoToTransfer do
  use Ecto.Migration

  def change do
    alter table(:transfers) do
      add :utxo, :text
    end
  end
end
