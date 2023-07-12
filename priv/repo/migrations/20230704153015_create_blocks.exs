defmodule Watcher.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      timestamps()

      add :block_number, :integer
      add :epoch_number, :integer
    end
  end
end
