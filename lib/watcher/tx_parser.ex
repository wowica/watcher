defmodule Watcher.TxParser do
  require Logger

  def parse(%{"txoutput" => content} = _payload) do
    %{
      "tx_output" => %{
        "address" => address,
        "amount" => amount
      }
    } = Jason.decode!(content)

    tx = %{address: address, amount: amount}

    Watcher.Dashboard.broadcast_tx_update(tx)

    Logger.info("Address #{address} received #{div(amount, 1_000_000)} ADA")
  end

  def parse(_payload) do
    Logger.info("Got message from stream")
  end
end
