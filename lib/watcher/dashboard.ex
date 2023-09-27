defmodule Watcher.Dashboard do
  import Ecto.Query

  alias Watcher.Block
  alias Watcher.PubSub
  alias Watcher.Repo
  alias Watcher.Transfer

  @max_length_records 50
  @pub_sub_topic "transactions"

  def subscribe_to_tx() do
    Phoenix.PubSub.subscribe(PubSub, @pub_sub_topic)
  end

  def broadcast_txs_update(txs) when is_list(txs) do
    Phoenix.PubSub.broadcast(
      Watcher.PubSub,
      @pub_sub_topic,
      {:txs_updated, txs}
    )
  end

  def create_transfer!(address, amount, timestamp, utxo) do
    %Transfer{}
    |> Transfer.changeset(%{
      receiving_address: address,
      amount: amount,
      timestamp: timestamp,
      utxo: utxo
    })
    |> Repo.insert!()
  end

  def create_block!(%{"number" => block_number, "epoch" => epoch_number} = _block_params) do
    %Block{}
    |> Block.changeset(%{
      block_number: block_number,
      epoch_number: epoch_number
    })
    |> Repo.insert!()
  end

  def broadcast_block_update(%Block{} = block) do
    Phoenix.PubSub.broadcast(
      Watcher.PubSub,
      @pub_sub_topic,
      {:block_updated, block}
    )
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

  def list_transfers_formatted do
    Transfer
    |> Repo.all()
    |> Enum.map(&{&1.receiving_address, &1.amount, &1.timestamp})
  end

  def get_most_recent_block_info do
    %Block{block_number: block_number, epoch_number: epoch_number} =
      from(b in Block, order_by: [desc: :inserted_at], limit: 1)
      |> Repo.one()

    {epoch_number, block_number}
  end

  def trim_block_records do
    all_above_threshold =
      from(t in Block,
        order_by: [desc: :inserted_at],
        offset: 1,
        select: %{id: t.id}
      )
      |> Repo.all()
      |> Enum.map(fn result -> result.id end)

    from(t in Block, where: t.id in ^all_above_threshold)
    |> Repo.delete_all()
  end
end
