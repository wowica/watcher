defmodule WatcherWeb.ViewHelper do
  @moduledoc """
  This module defines helper functions for formatting view content
  """

  def format_address(full_address, is_sm \\ false) do
    range =
      if is_sm do
        {0..10, -8..-1}
      else
        {0..15, -15..-1}
      end

    String.slice(full_address, elem(range, 0)) <>
      "..." <> String.slice(full_address, elem(range, 1))
  end

  def format_amount(amount_in_lovelace) do
    (amount_in_lovelace / 1_000_000)
    |> Float.round(2)
    |> Number.Currency.number_to_currency(unit: "")
  end

  def format_date(date) do
    DateTime.from_unix!(date) |> DateTime.to_string()
  end
end
