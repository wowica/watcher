defmodule Watcher.TxParser do
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

    tx = %{address: address, amount: amount, timestamp: timestamp}

    Watcher.Dashboard.broadcast_tx_update(tx)

    Logger.info("Address #{address} received #{div(amount, 1_000_000)} ADA")
  end

  def parse(payload) do
    Logger.info("Got message from stream #{inspect(payload)}")
  end
end
