defmodule WatcherWeb.DashboardLive.Index do
  use WatcherWeb, :live_view

  require Logger

  alias Watcher.Dashboard

  @impl true
  def mount(_params, _session, socket) do
    {txs, epoch_number, block_number} =
      if connected?(socket) do
        Dashboard.subscribe_to_tx()

        load_dashboard_data()
      else
        load_dashboard_data()
      end

    {:ok,
     socket
     |> assign(:epoch_number, epoch_number)
     |> assign(:block_number, block_number)
     |> assign(:transactions, txs)
     |> assign(:last_updated_at, last_updated_at())}
  end

  defp load_dashboard_data do
    {epoch_number, block_number} = Dashboard.get_most_recent_block_info()

    {Dashboard.list_transfers_formatted(), epoch_number, block_number}
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

  @impl true
  def handle_info(
        {:block_updated,
         %Watcher.Block{
           block_number: block_number,
           epoch_number: epoch_number
         } = _block},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:epoch_number, epoch_number)
     |> assign(:block_number, block_number)
     |> assign(:last_updated_at, last_updated_at())}
  end

  defp last_updated_at do
    DateTime.now!("Etc/UTC")
    |> DateTime.to_string()
    |> String.slice(0, 16)
    |> Kernel.<>(" UTC")
  end
end
