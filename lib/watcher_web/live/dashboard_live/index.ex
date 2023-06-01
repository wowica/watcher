defmodule WatcherWeb.DashboardLive.Index do
  use WatcherWeb, :live_view

  require Logger

  alias Watcher.Dashboard

  @impl true
  def mount(_params, _session, socket) do
    txs =
      if connected?(socket) do
        Dashboard.subscribe_to_tx()

        Dashboard.list_transfers_formatted()
      end

    {:ok,
     socket
     |> assign(:transactions, txs || [])
     |> assign(:last_updated_at, last_updated_at())}
  end

  @impl true
  def handle_info(
        {:tx_updated,
         %Watcher.Transfer{
           receiving_address: address,
           amount: amount,
           timestamp: timestamp
         } = _tx},
        socket
      ) do
    txs = socket.assigns.transactions

    all_txs =
      ([{address, amount, timestamp}] ++ txs)
      |> Enum.slice(0, 50)

    {:noreply,
     socket
     |> assign(:transactions, all_txs)
     |> assign(:last_updated_at, last_updated_at())}
  end

  defp last_updated_at do
    DateTime.now!("Etc/UTC")
    |> DateTime.to_string()
    |> String.slice(0, 16)
    |> Kernel.<>(" UTC")
  end
end
