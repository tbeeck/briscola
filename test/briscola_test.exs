defmodule BriscolaTest do
  use ExUnit.Case
  doctest Briscola

  test "new deck has right number of cards" do
    # 4 Suits, 10 ranks
    assert 4*10 == length(Briscola.new_deck().cards)
  end

  describe "faces" do
    test "1 is ace" do
      assert :ace == Briscola.face(%Briscola.Card{rank: 1, suit: :cups})
    end
    test "8 is jack" do
      assert :jack == Briscola.face(%Briscola.Card{rank: 8, suit: :cups})
    end
    test "9 is knight" do
      assert :knight == Briscola.face(%Briscola.Card{rank: 9, suit: :cups})
    end
    test "10 is king" do
      assert :king == Briscola.face(%Briscola.Card{rank: 10, suit: :cups})
    end
  end
end
