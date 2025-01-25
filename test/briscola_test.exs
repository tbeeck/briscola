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

    test "other ranks have no face" do
      Enum.each(2..10, fn rank ->
        assert :none == Briscola.Card.face(%Briscola.Card{rank: rank, suit: :cups})
      end)
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

    test "new game has no lead suit" do
      game = Briscola.Game.new()
      assert nil == Briscola.Game.lead_suit(game)
    end
  end

  describe "game rules" do
    test "one player takes trick" do
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

    test "cannot prematurely score trick" do
      game = Briscola.Game.new(players: 4)
      assert {:error, :trick_not_over} == Briscola.Game.score_trick(game)

      game = Briscola.Game.new(players: 4)
      {:ok, game} = Briscola.Game.play(game, 0)
      assert {:error, :trick_not_over} == Briscola.Game.score_trick(game)
      assert {:error, :trick_not_over} == Briscola.Game.score_trick(game)
      assert {:error, :trick_not_over} == Briscola.Game.score_trick(game)
    end

    test "briscola suit beats lead suit" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([%Briscola.Card{rank: 4, suit: :batons}])
        |> TestGame.hand(0, [%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.action_on(0)

      {:ok, game} = Briscola.Game.play(game, 0)

      {:ok, game, winning_player} = Briscola.Game.score_trick(game)

      # First player won the trick
      assert 0 == winning_player
      assert 2 == length(Enum.at(game.players, 0).pile)
    end

    test "lead suit beats others" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :batons})
        |> TestGame.trick([%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.hand(1, [%Briscola.Card{rank: 4, suit: :coins}])
        |> TestGame.action_on(1)

      {:ok, game} = Briscola.Game.play(game, 0)

      {:ok, game, winning_player} = Briscola.Game.score_trick(game)

      # First player played the lead suit
      assert 0 == winning_player
      assert 2 == length(Enum.at(game.players, 0).pile)
    end

    test "trump suit beats others" do
      game =
        TestGame.new(players: 4)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([
          %Briscola.Card{rank: 4, suit: :coins},
          %Briscola.Card{rank: 5, suit: :coins},
          %Briscola.Card{rank: 6, suit: :coins}
        ])
        |> TestGame.hand(3, [%Briscola.Card{rank: 3, suit: :cups}])
        |> TestGame.action_on(3)

      {:ok, game} = Briscola.Game.play(game, 0)

      {:ok, game, winning_player} = Briscola.Game.score_trick(game)

      # Last player played trump suit
      assert 3 == winning_player
      assert 4 == length(Enum.at(game.players, 3).pile)
    end

    test "high rank beats low rank" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.hand(1, [%Briscola.Card{rank: 5, suit: :cups}])
        |> TestGame.action_on(1)

      {:ok, game} = Briscola.Game.play(game, 0)

      {:ok, game, winning_player} = Briscola.Game.score_trick(game)

      # Second player played a higher rank
      assert 1 == winning_player
      assert 2 == length(Enum.at(game.players, 1).pile)
    end

    test "can play specific card" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.hand(1, [%Briscola.Card{rank: 5, suit: :cups}])
        |> TestGame.action_on(1)

      {:ok, game} = Briscola.Game.play(game, %Briscola.Card{rank: 5, suit: :cups})
      assert %Briscola.Card{rank: 5, suit: :cups} == List.first(game.trick)
    end

    test "cant play nonexistent card" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([%Briscola.Card{rank: 3, suit: :cups}])
        |> TestGame.hand(1, [%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.action_on(1)

      assert {:error, :invalid_card} ==
               Briscola.Game.play(game, %Briscola.Card{rank: 5, suit: :cups})
    end

    test "cannot redeal before trick is scored" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 1, suit: :cups})
        |> TestGame.trick([
          %Briscola.Card{rank: 2, suit: :cups},
          %Briscola.Card{rank: 3, suit: :cups}
        ])
        |> TestGame.fill_hands(2)

      {:error, :trick_not_scored} = Briscola.Game.redeal(game)
    end

    test "cannot redeal if players have all cards" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 1, suit: :cups})
        |> TestGame.fill_hands(3)

      {:error, :players_have_cards} = Briscola.Game.redeal(game)
    end

    test "redeal gives cards back after a trick" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 1, suit: :cups})
        |> TestGame.trick([
          %Briscola.Card{rank: 2, suit: :cups},
          %Briscola.Card{rank: 3, suit: :cups}
        ])
        |> TestGame.fill_hands(2)

      game =
        Briscola.Game.score_trick(game)
        |> elem(1)
        |> Briscola.Game.redeal()

      assert Enum.all?(game.players, fn p -> length(p.hand) == 3 end)
    end

    test "last player gets briscola card on final redeal" do
      # todo
    end
  end

  describe "scoring" do
    test "score aces" do
      assert 11 == Briscola.Card.score(%Briscola.Card{rank: 1, suit: :cups})
    end

    test "score 3s" do
      assert 10 == Briscola.Card.score(%Briscola.Card{rank: 3, suit: :cups})
    end

    test "score kings" do
      assert 4 == Briscola.Card.score(%Briscola.Card{rank: 13, suit: :cups})
    end

    test "score knights" do
      assert 3 == Briscola.Card.score(%Briscola.Card{rank: 12, suit: :cups})
    end

    test "score jacks" do
      assert 2 == Briscola.Card.score(%Briscola.Card{rank: 11, suit: :cups})
    end

    test "score other cards" do
      assert 0 == Briscola.Card.score(%Briscola.Card{rank: 2, suit: :cups})
    end

    test "player score is sum of pile scores" do
      player = %Briscola.Player{
        hand: [],
        pile: [
          %Briscola.Card{rank: 1, suit: :cups},
          %Briscola.Card{rank: 3, suit: :cups},
          %Briscola.Card{rank: 13, suit: :cups},
          %Briscola.Card{rank: 12, suit: :cups},
          %Briscola.Card{rank: 11, suit: :cups},
          %Briscola.Card{rank: 2, suit: :cups}
        ]
      }

      assert 30 == Briscola.Player.score(player)
    end
  end

  describe "sim games" do
    test "sim one turn" do
      game =
        Briscola.Game.new(players: 4)
        |> TestGame.sim_trick()

      # Original deck: 52 cards
      # initial deal: 3 cards for 4 players
      # next deal: 3 cards for 4 players
      # briscola: 1
      assert 52 - (3 * 4 + 4) - 1 == length(game.deck.cards)
    end

    test "sim all tricks" do
      players = 4
      tricks_to_complete = Integer.floor_div(52, players)

      game =
        Enum.reduce(1..tricks_to_complete, Briscola.Game.new(players: players), fn _, game_acc ->
          TestGame.sim_trick(game_acc)
        end)

      assert 0 == length(game.deck.cards)
      assert 52 == Enum.reduce(game.players, 0, fn player, acc -> acc + length(player.pile) end)
    end
  end
end
