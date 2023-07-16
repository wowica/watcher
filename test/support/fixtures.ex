defmodule Watcher.Fixtures do
  @moduledoc """
  This modules provides fixtures for tests
  """

  alias Watcher.Block
  alias Watcher.Repo
  alias Watcher.Transfer

  def create_valid_block() do
    %Block{}
    |> Block.changeset(%{
      block_number: 123_123_123,
      epoch_number: 666
    })
    |> Repo.insert!()
  end

  def create_valid_transfer() do
    %Transfer{}
    |> Transfer.changeset(%{
      receiving_address: "addr_test123123123",
      amount: 123_123_123,
      timestamp: DateTime.utc_now() |> DateTime.to_unix()
    })
    |> Repo.insert!()
  end
end
