defmodule Watcher.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transfers" do
    field :amount, :integer
    field :receiving_address, :string
    field :utxo, :string
    field :timestamp, :integer

    timestamps()
  end

  @doc false
  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, [:receiving_address, :amount, :utxo, :timestamp])
    |> validate_required([:receiving_address, :amount, :utxo, :timestamp])
  end
end
