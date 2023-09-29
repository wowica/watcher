defmodule Watcher.TxBuffer do
  @moduledoc """
  Buffers data coming in from Redis stream to avoid overloading
  the LiveView socket with too much data at once.
  """
  use Agent

  @default_opts [buffer_size: 15, name: __MODULE__]

  def start_link(initial_opts \\ []) do
    opts = Keyword.merge(@default_opts, initial_opts)
    Agent.start_link(fn -> {opts[:buffer_size], []} end, name: opts[:name])
  end

  def add_tx(pid, tx, func) do
    Agent.update(pid, fn
      {buffer_size, all_txs} when length(all_txs) < buffer_size - 1 ->
        {buffer_size, [tx | all_txs]}

      {buffer_size, all_txs} ->
        func.([tx | all_txs])
        {buffer_size, []}
    end)
  end

  def get_txs(pid) do
    Agent.get(pid, fn {_buffer_size, txs} -> txs end)
  end
end
