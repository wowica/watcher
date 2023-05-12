defmodule WatcherWeb.DashboardLive.Index do
  use WatcherWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Watcher.Dashboard.subscribe_to_tx()
    end

    {:ok, assign(socket, :transactions, [])}
  end

  @impl true
  def handle_info(
        {:tx_updated, %{address: address, amount: amount} = _tx},
        socket
      ) do
    txs = socket.assigns.transactions
    {:noreply, assign(socket, :transactions, [{address, amount}] ++ txs)}
  end
end
