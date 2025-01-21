defmodule BriscolaTest do
  use ExUnit.Case
  doctest Briscola

  describe "deck" do
    test "new deck has right number of cards" do
      # 4 Suits, 13 ranks
      assert 4 * 13 == length(Briscola.Deck.new().cards)
    end

    test "shuffled deck is different" do
      deck = Briscola.Deck.new()
      shuffled = Briscola.Deck.shuffle(deck)
      refute deck == shuffled
    end
  end

  describe "faces" do
    test "1 is ace" do
      assert :ace == Briscola.face(%Briscola.Card{rank: 1, suit: :cups})
    end

    test "11 is jack" do
      assert :jack == Briscola.face(%Briscola.Card{rank: 11, suit: :cups})
    end

    test "12 is knight" do
      assert :knight == Briscola.face(%Briscola.Card{rank: 12, suit: :cups})
    end

    test "13 is king" do
      assert :king == Briscola.face(%Briscola.Card{rank: 13, suit: :cups})
    end
  end

  describe "make a new game" do
    test "new game has a deck" do
      game = Briscola.Game.new()
      assert game.deck
    end

    test "new game has players" do
      game = Briscola.Game.new()
      assert game.players
    end

    test "new game has hands" do
      game = Briscola.Game.new()
      assert game.hands
    end

    test "new game has a briscola" do
      game = Briscola.Game.new()
      assert game.briscola
    end

    test "new game has a trick" do
      game = Briscola.Game.new()
      assert game.trick
    end

    test "new game has a trump suit" do
      game = Briscola.Game.new()
      assert game.briscola.suit == Briscola.Game.trump_suit(game)
    end
  end
end
