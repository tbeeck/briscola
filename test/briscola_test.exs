defmodule BriscolaTest do
  use ExUnit.Case
  doctest Briscola

  describe "deck" do
    test "new deck has right number of cards" do
      # 4 Suits, 13 ranks
      assert 4 * 13 == length(Briscola.Deck.new().cards)
    end
  end

  describe "shuffle" do
    test "shuffled deck is different" do
      deck = Briscola.Deck.new()
      shuffled = Briscola.shuffle(deck)
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
end
