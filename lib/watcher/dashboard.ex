defmodule Watcher.Dashboard do
  import Ecto.Query

  alias Watcher.PubSub
  alias Watcher.Repo
  alias Watcher.Transfer

  @max_length_records 50
  @pub_sub_topic "transactions"

  def subscribe_to_tx() do
    Phoenix.PubSub.subscribe(PubSub, @pub_sub_topic)
  end

  def broadcast_tx_update(%Transfer{} = tx) do
    Phoenix.PubSub.broadcast(
      Watcher.PubSub,
      @pub_sub_topic,
      {:tx_updated, tx}
    )
  end

  def create_transfer!(address, amount, timestamp) do
    %Transfer{}
    |> Transfer.changeset(%{
      receiving_address: address,
      amount: amount,
      timestamp: timestamp
    })
    |> Repo.insert!()
  end

  # Keeps database from growing too long
  def trim_records do
    # TODO: figure out how to trim records in a single query
    # Repo.delete_all does not work on the first query.
    all_above_threshold =
      from(t in Transfer,
        order_by: [desc: :inserted_at],
        offset: @max_length_records,
        select: %{id: t.id}
      )
      |> Repo.all()
      |> Enum.map(fn result -> result.id end)

    from(t in Transfer, where: t.id in ^all_above_threshold)
    |> Repo.delete_all()
  end
end
