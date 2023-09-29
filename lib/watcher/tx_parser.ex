defmodule Watcher.TxParser do
  @moduledoc """
  Parses transactions coming from Oura and dispatches them to the rest of the app.
  """
  alias Watcher.Dashboard
  alias Watcher.TxBuffer

  def parse(%{"txoutput" => content} = _payload, buffer_pid) do
    %{
      "tx_output" => %{
        "address" => address,
        "amount" => amount
      },
      "context" => %{
        "timestamp" => timestamp,
        "tx_hash" => tx_hash,
        "output_idx" => output_idx
      }
    } = Jason.decode!(content)

    utxo = "#{tx_hash}##{output_idx}"
    tx = Dashboard.create_transfer!(address, amount, timestamp, utxo)

    TxBuffer.add_tx(buffer_pid, tx, fn _all_txs_in_the_buffer ->
      Dashboard.trim_records()

      Dashboard.list_transfers_formatted()
      |> Dashboard.broadcast_txs_update()
    end)

    :ok
  end

  def parse(%{"block" => block_content}, _buffer_pid) do
    %{"block" => block_params} = Jason.decode!(block_content)

    Dashboard.create_block!(block_params)
    |> Dashboard.broadcast_block_update()

    Dashboard.trim_block_records()

    :ok
  end

  def parse(_payload, _pid) do
    :ok
  end

  # This function is for OuraV2
  # Strictly used for local development for the time being.
  # def parse(event_payload) do
  #   # The new redis entry format for OuraV2 is a single key
  #   # being the timestamp of the entry.
  #   [event] = Map.values(event_payload)

  #   case Jason.decode!(event) do
  #     %{
  #       "context" => %{"output_address" => addr},
  #       "output_asset" => output_asset
  #     } = _event_data_decoded
  #     when not is_nil(addr) ->
  #       %{"amount" => amount, "asset_ascii" => asset_name} = output_asset
  #       # Logger.info("address #{addr}\t amount: #{amount} #{asset_name}")
  #       :ok

  #     %{"tx_output" => %{"address" => addr, "amount" => amount}} ->
  #       # Logger.info("address #{addr}\t amount: #{amount} ADA")
  #       :ok

  #     _decoded ->
  #       # Logger.info("No output address #{inspect(Map.keys(decoded))}")
  #       :ok
  #   end
  # end
end
