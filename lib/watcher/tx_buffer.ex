defmodule Watcher.TxBuffer do
  use GenServer

  @default_opts [buffer_size: 50, name: __MODULE__]

  def start_link(initial_opts \\ []) do
    opts = Keyword.merge(@default_opts, initial_opts)

    GenServer.start_link(__MODULE__, opts[:buffer_size], name: opts[:name])
  end

  def add_tx(pid, tx, func) do
    GenServer.cast(pid, {:add_tx, tx, func})
  end

  def get_txs(pid) do
    GenServer.call(pid, :get_txs)
  end

  @impl true
  def init(buffer_size) do
    # State is a tuple
    initial_state = {buffer_size, _buffer_elements = []}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:get_txs, _from, {_buffer_size, txs} = state) do
    {:reply, txs, state}
  end

  @impl true
  def handle_cast({:add_tx, tx, func}, {buffer_size, all_txs} = _state) do
    new_txs = [tx | all_txs]

    if length(new_txs) >= buffer_size do
      func.(new_txs)
      {:noreply, {buffer_size, []}}
    else
      {:noreply, {buffer_size, new_txs}}
    end
  end
end
