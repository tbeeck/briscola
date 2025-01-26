defmodule Briscola.Strategy.Strongest do
  @moduledoc """
  A briscola strategy that chooses the strongest card from the player's hand.
  """

  @behaviour Briscola.Strategy

  @impl Briscola.Strategy
  def choose_card(game, player_index) do
    hand = Enum.at(game.players, player_index).hand
    strongest_card = Enum.max_by(hand, &Briscola.Card.strength/1)
    Enum.find_index(hand, &(&1 == strongest_card))
  end
end
