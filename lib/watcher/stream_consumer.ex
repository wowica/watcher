defmodule Watcher.StreamConsumer do
  @moduledoc """
  Connects to the Redis stream and initializes the TxBuffer process.
  Reads raw data from the stream and passes it along to TxParser.
  """
  use GenServer

  alias Watcher.TxBuffer
  alias Watcher.TxParser

  require Logger

  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(_opts) do
    {:ok,
     %{
       host: redis_host(),
       stream_name: redis_stream_name()
     }, {:continue, :listen}}
  end

  def handle_continue(:listen, %{host: host, stream_name: stream_name} = state) do
    {:ok, conn} = Redix.start_link(host)
    {:ok, tx_buffer_pid} = TxBuffer.start_link()

    Redix.Stream.Consumer.start_link(conn, stream_name, {__MODULE__, :consume, [tx_buffer_pid]})

    {:noreply, state}
  end

  def consume(pid, _stream, _id, payload),
    do: TxParser.parse(payload, pid)

  defp redis_host do
    Application.fetch_env!(:watcher, __MODULE__)
    |> Keyword.fetch!(:redis_host)
  end

  defp redis_stream_name do
    Application.fetch_env!(:watcher, __MODULE__)
    |> Keyword.fetch!(:redis_stream_name)
  end
end
