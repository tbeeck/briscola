defmodule BriscolaTest.Strategy do
  use ExUnit.Case

  alias Briscola.GameFixture, as: TestGame

  describe "Strongest" do
    alias Briscola.Strategy.Strongest

    test "chooses the strongest card from the player's hand" do
      game = Briscola.Game.new(players: 4)
      player_index = 0
      hand = Enum.at(game.players, player_index).hand

      strongest_card_index =
        Enum.with_index(hand)
        |> Enum.max_by(fn {card, _idx} -> Briscola.Card.strength(card) end)
        |> elem(1)

      assert strongest_card_index == Strongest.choose_card(game, player_index)
    end
  end

  describe "Random" do
    alias Briscola.Strategy.Random

    test "chooses a random card from the player's hand" do
      game = TestGame.new()
      player_index = 0
      hand_length = length(Enum.at(game.players, player_index).hand)
      assert Random.choose_card(game, player_index) in 0..(hand_length - 1)
    end
  end
end
