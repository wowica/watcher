defmodule Watcher.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transfers" do
    field :amount, :integer
    field :receiving_address, :string
    field :timestamp, :integer

    timestamps()
  end

  @doc false
  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, [:receiving_address, :amount, :timestamp])
    |> validate_required([:receiving_address, :amount, :timestamp])
  end
end
