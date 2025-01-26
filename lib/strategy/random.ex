defmodule Briscola.Strategy.Random do
  @moduledoc """
  A briscola strategy that chooses a random card from the player's hand.
  """

  @behaviour Briscola.Strategy

  @impl Briscola.Strategy
  def choose_card(game, player_index) do
    hand_length = length(Enum.at(game.players, player_index).hand)
    Enum.random(0..(hand_length - 1))
  end
end
