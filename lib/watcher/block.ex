defmodule Watcher.Block do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(block_number epoch_number)a

  schema "blocks" do
    field :block_number, :integer
    field :epoch_number, :integer

    timestamps()
  end

  @doc false
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
