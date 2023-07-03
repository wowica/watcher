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

  # This function is for OuraV2
  # Strictly used for local development for the time being.
  def parse(event_payload) do
    # The new redis entry format for OuraV2 is a single key
    # being the timestamp of the entry.
    [event] = Map.values(event_payload)

    case Jason.decode!(event) do
      %{
        "context" => %{"output_address" => addr},
        "output_asset" => output_asset
      } = _event_data_decoded
      when not is_nil(addr) ->
        %{"amount" => amount, "asset_ascii" => asset_name} = output_asset
        Logger.info("address #{addr}\t amount: #{amount} #{asset_name}")
        :ok

      %{"tx_output" => %{"address" => addr, "amount" => amount}} ->
        Logger.info("address #{addr}\t amount: #{amount} ADA")
        :ok

      decoded ->
        Logger.info("No output address #{inspect(Map.keys(decoded))}")
        :ok
    end
  end
end
