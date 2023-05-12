defmodule WatcherWeb.DashboardLive.Index do
  use WatcherWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Watcher.Dashboard.subscribe_to_tx()
    end

    {:ok,
     socket
     |> assign(:transactions, [])
     |> assign(:last_updated_at, last_updated_at())}
  end

  @impl true
  def handle_info(
        {:tx_updated, %{address: address, amount: amount, timestamp: timestamp} = _tx},
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
