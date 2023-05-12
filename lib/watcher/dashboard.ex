defmodule Watcher.Dashboard do
  @pub_sub_topic "transactions"

  def subscribe_to_tx() do
    Phoenix.PubSub.subscribe(Watcher.PubSub, @pub_sub_topic)
  end

  def broadcast_tx_update(tx) do
    Phoenix.PubSub.broadcast(
      Watcher.PubSub,
      @pub_sub_topic,
      {:tx_updated, tx}
    )
  end
end
