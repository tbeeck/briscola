defmodule BriscolaTest do
  use ExUnit.Case
  doctest Briscola

  test "new deck has right number of cards" do
    # 4 Suits, 10 ranks
    assert length(Briscola.new_deck().cards) == 4 * 10
  end
end
