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
     |> assign(:last_updated_at, last_updated_at()), temporary_assigns: [transactions: []]}
  end

  defp load_dashboard_data do
    {epoch_number, block_number} = Dashboard.get_most_recent_block_info()

    {Dashboard.list_transfers_formatted(), epoch_number, block_number}
  end

  @impl true
  def handle_info(
        {:txs_updated, recent_txs},
        socket
      ) do
    send(self(), :reset_counter)

    {:noreply,
     socket
     |> update(:transactions, fn _txs -> recent_txs end)
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
    send(self(), :reset_counter)

    {:noreply,
     socket
     |> assign(:epoch_number, epoch_number)
     |> assign(:block_number, block_number)
     |> assign(:last_updated_at, last_updated_at())}
  end

  @impl true
  def handle_info(:reset_counter, socket) do
    {:noreply, push_event(socket, "resetCounter", %{})}
  end

  defp last_updated_at do
    DateTime.now!("Etc/UTC")
    |> DateTime.to_string()
    |> String.slice(0, 16)
    |> Kernel.<>(" UTC")
  end
end
