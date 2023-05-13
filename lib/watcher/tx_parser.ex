defmodule Watcher.TxParser do
  alias Watcher.Dashboard
  require Logger

  def parse(%{"txoutput" => content} = _payload) do
    %{
      "tx_output" => %{
        "address" => address,
        "amount" => amount
      },
      "context" => %{
        "timestamp" => timestamp
      }
    } = Jason.decode!(content)

    Dashboard.create_transfer!(address, amount, timestamp)
    |> Dashboard.broadcast_tx_update()

    Dashboard.trim_records()

    Logger.info("Address #{address} received #{div(amount, 1_000_000)} ADA at #{timestamp}")
  end

  def parse(payload) do
    Logger.info("Got message from stream #{inspect(payload)}")
  end
end
