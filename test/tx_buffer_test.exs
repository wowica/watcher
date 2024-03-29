defmodule Watcher.TxBufferTest do
  use ExUnit.Case, async: true

  alias Watcher.TxBuffer

  test "does not flush until buffer is met", %{test: name} do
    pid = start_supervised!({TxBuffer, name: name, buffer_size: 3})

    my_pid = self()

    tx1 = "foo"
    tx2 = "bar"

    _ =
      TxBuffer.add_tx(pid, tx1, fn _txs ->
        send(my_pid, :did_not_flush_to_socket)
      end)

    _ =
      TxBuffer.add_tx(pid, tx2, fn _txs ->
        send(my_pid, :did_not_flush_to_socket)
      end)

    refute_receive :did_not_flush_to_socket, 500
  end

  test "flushes when buffer is met", %{test: name} do
    pid = start_supervised!({TxBuffer, name: name, buffer_size: 3})

    my_pid = self()

    tx1 = "foo"
    tx2 = "bar"
    tx3 = "baz"

    _ =
      TxBuffer.add_tx(pid, tx1, fn _txs ->
        send(my_pid, :did_not_flush_to_socket)
      end)

    refute_receive :did_not_flush_to_socket, 500
    assert [^tx1] = TxBuffer.get_txs(pid)

    _ =
      TxBuffer.add_tx(pid, tx2, fn _txs ->
        send(my_pid, :did_not_flush_to_socket)
      end)

    refute_receive :did_not_flush_to_socket, 500

    all_txs = TxBuffer.get_txs(pid)
    assert Enum.all?([tx1, tx2], &(&1 in all_txs))

    _ =
      TxBuffer.add_tx(pid, tx3, fn _txs ->
        send(my_pid, :flush_to_socket)
      end)

    assert_receive :flush_to_socket, 500
    assert [] == TxBuffer.get_txs(pid)
  end
end
