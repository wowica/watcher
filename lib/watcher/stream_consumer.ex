defmodule Watcher.StreamConsumer do
  use GenServer

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

    Redix.Stream.Consumer.start_link(conn, stream_name, {__MODULE__, :consume, []})

    {:noreply, state}
  end

  def consume(_stream, _id, %{"txoutput" => content} = _txoutput) do
    %{
      "tx_output" => %{
        "address" => address,
        "amount" => amount
      }
    } = Jason.decode!(content)

    Logger.info("Address #{address} received #{div(amount, 1_000_000)} ADA")
  end

  def consume(_stream, _id, _values) do
    Logger.info("Got message from stream")
  end

  defp redis_host do
    Application.fetch_env!(:watcher, __MODULE__)
    |> Keyword.fetch!(:redis_host)
  end

  defp redis_stream_name do
    Application.fetch_env!(:watcher, __MODULE__)
    |> Keyword.fetch!(:redis_stream_name)
  end
end
