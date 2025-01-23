defmodule BriscolaTest do
  use ExUnit.Case

  alias Briscola.GameFixture, as: TestGame

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
      assert :ace == Briscola.Card.face(%Briscola.Card{rank: 1, suit: :cups})
    end

    test "11 is jack" do
      assert :jack == Briscola.Card.face(%Briscola.Card{rank: 11, suit: :cups})
    end

    test "12 is knight" do
      assert :knight == Briscola.Card.face(%Briscola.Card{rank: 12, suit: :cups})
    end

    test "13 is king" do
      assert :king == Briscola.Card.face(%Briscola.Card{rank: 13, suit: :cups})
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

    test "players start with 3 cards" do
      game = Briscola.Game.new()
      assert Enum.all?(game.players, fn player -> length(player.hand) == 3 end)
    end
  end

  describe "game rules" do
    test "complete a trick 4 players" do
      game = Briscola.Game.new(players: 4)
      {:ok, game} = Briscola.Game.play(game, 0)
      {:ok, game} = Briscola.Game.play(game, 0)
      {:ok, game} = Briscola.Game.play(game, 0)
      {:ok, game} = Briscola.Game.play(game, 0)
      assert {:error, :trick_over} == Briscola.Game.play(game, 0)
      {:ok, game, _winning_player} = Briscola.Game.score_trick(game)

      assert 1 == Enum.count(game.players, fn player -> length(player.pile) == 4 end)
      assert 4 == Enum.count(game.players, fn player -> length(player.hand) == 2 end)
    end

    test "briscola suit beats lead suit" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.hand(0, [%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.action_on(0)
        |> TestGame.trick([%Briscola.Card{rank: 4, suit: :batons}])

      {:ok, game} = Briscola.Game.play(game, 0)

      {:ok, game, winning_player} = Briscola.Game.score_trick(game)

      # First player won the trick
      assert 0 == winning_player
      assert 2 == length(Enum.at(game.players, 0).pile)
    end
  end
end
