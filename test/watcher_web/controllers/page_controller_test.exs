defmodule WatcherWeb.PageControllerTest do
  use WatcherWeb.ConnCase

  alias Watcher.Fixtures

  setup do
    block = Fixtures.create_valid_block()
    transfer = Fixtures.create_valid_transfer()

    %{block: block, transfer: transfer}
  end

  test "GET /", %{conn: conn, block: block, transfer: transfer} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~ "Block Explorer"
    assert html_response(conn, 200) =~ "#{block.epoch_number}"
    assert html_response(conn, 200) =~ "#{block.block_number}"
    assert html_response(conn, 200) =~ "#{transfer.receiving_address}"
  end
end
