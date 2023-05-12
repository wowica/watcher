defmodule WatcherWeb.ViewHelper do
  @moduledoc """
  This module defines helper functions for formatting view content
  """
  def format_address(full_address) do
    String.slice(full_address, 0..15) <> "..." <> String.slice(full_address, -15..-1)
  end

  def format_amount(amount_in_lovelace) do
    "#{div(amount_in_lovelace, 1_000_000)} ADA"
  end

  def format_date(date) do
    DateTime.from_unix!(date) |> DateTime.to_string()
  end
end
