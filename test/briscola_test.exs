defmodule BriscolaTest do
  use ExUnit.Case

  alias Briscola.GameFixture, as: TestGame

  doctest Briscola

  describe "deck" do
    test "new deck has right number of cards" do
      assert 4 * 10 == length(Briscola.Deck.new().cards)
    end

    test "shuffled deck is different" do
      deck = Briscola.Deck.new()
      shuffled = Briscola.Deck.shuffle(deck)
      refute deck == shuffled
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

    test "game has a current player" do
      game = Briscola.Game.new()
      assert 0 == game.action_on
    end

    test "game can be created with 4 players" do
      game = Briscola.Game.new(players: 4)
      assert 4 == length(game.players)
    end

    test "game can be created with 2 players" do
      game = Briscola.Game.new(players: 2)
      assert 2 == length(game.players)
    end

    test "game cannot be created with 1 player" do
      assert_raise ArgumentError, fn ->
        Briscola.Game.new(players: 1)
      end
    end

    test "player count defaults to 2" do
      game = Briscola.Game.new()
      assert 2 == length(game.players)
    end

    test "game starts with specified player" do
      game = Briscola.Game.new(players: 2, goes_first: 1)
      assert 1 == game.action_on
    end

    test "game starts with first player by default" do
      game = Briscola.Game.new(players: 2)
      assert 0 == game.action_on
    end

    test "raise error for invalid first player" do
      assert_raise ArgumentError, fn ->
        Briscola.Game.new(players: 2, goes_first: 2)
      end

      assert_raise ArgumentError, fn ->
        Briscola.Game.new(players: 2, goes_first: -1)
      end
    end
  end

  describe "player turn-taking" do
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

    test "can't play nonexistent card" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([%Briscola.Card{rank: 3, suit: :cups}])
        |> TestGame.hand(1, [%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.action_on(1)

      assert {:error, :invalid_card} ==
               Briscola.Game.play(game, %Briscola.Card{rank: 5, suit: :cups})

      # Players will never have 4 cards
      assert {:error, :invalid_card} ==
               Briscola.Game.play(game, 4)
    end

    test "playing a card moves action to the next player" do
      turn_order = %{0 => 1, 1 => 2, 2 => 3, 3 => 0}

      scenario =
        TestGame.new(players: 4)
        |> TestGame.briscola(%Briscola.Card{rank: 1, suit: :cups})
        |> TestGame.fill_hands(3)

      Enum.each(turn_order, fn {pa, pb} ->
        {:ok, next_turn} = scenario |> TestGame.action_on(pa) |> Briscola.Game.play(0)
        assert pb == next_turn.action_on
      end)
    end
  end

  describe "trick scoring" do
    test "cannot prematurely score trick" do
      game = Briscola.Game.new(players: 4)
      assert {:error, :trick_not_over} == Briscola.Game.score_trick(game)

      game = Briscola.Game.new(players: 4)
      {:ok, game} = Briscola.Game.play(game, 0)
      {:ok, game} = Briscola.Game.play(game, 0)
      {:ok, game} = Briscola.Game.play(game, 0)
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

    test "high rank wins if played before low rank" do
      game =
        TestGame.new(players: 2)
        |> TestGame.briscola(%Briscola.Card{rank: 2, suit: :cups})
        |> TestGame.trick([%Briscola.Card{rank: 5, suit: :cups}])
        |> TestGame.hand(1, [%Briscola.Card{rank: 4, suit: :cups}])
        |> TestGame.action_on(1)

      {:ok, game} = Briscola.Game.play(game, 0)

      {:ok, game, winning_player} = Briscola.Game.score_trick(game)

      # First player played a higher rank
      assert 0 == winning_player
      assert 2 == length(Enum.at(game.players, 0).pile)
    end
  end

  describe "dealing" do
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

    test "last player gets briscola card on final redeal with 2 players" do
      briscola = %Briscola.Card{rank: 1, suit: :cups}

      # Player 1 wins the trick
      {:ok, game, 0} =
        TestGame.new(players: 2)
        |> TestGame.briscola(briscola)
        |> TestGame.trick([
          %Briscola.Card{rank: 2, suit: :cups},
          %Briscola.Card{rank: 3, suit: :cups}
        ])
        |> TestGame.action_on(0)
        |> TestGame.deck([%Briscola.Card{rank: 4, suit: :cups}])
        |> Briscola.Game.score_trick()

      game = Briscola.Game.redeal(game)

      # Player 2 lost so they get the briscola card
      p2 = Enum.at(game.players, 1)
      assert Enum.any?(p2.hand, fn card -> card == briscola end)
    end

    test "last player gets briscola card on final redeal with 4 players" do
      briscola = %Briscola.Card{rank: 1, suit: :cups}

      # Player 1 wins the trick
      {:ok, game, 0} =
        TestGame.new(players: 4)
        |> TestGame.trick([
          %Briscola.Card{rank: 4, suit: :cups},
          %Briscola.Card{rank: 5, suit: :cups},
          %Briscola.Card{rank: 6, suit: :cups},
          %Briscola.Card{rank: 7, suit: :cups}
        ])
        |> TestGame.action_on(0)
        |> TestGame.briscola(briscola)
        |> TestGame.deck(
          Enum.reduce(8..10, [], fn i, acc -> [%Briscola.Card{rank: i, suit: :cups} | acc] end)
        )
        |> Briscola.Game.score_trick()

      game = Briscola.Game.redeal(game)

      # Player 4 is furthest from player 1, they get the briscola
      p4 = Enum.at(game.players, 3)
      assert Enum.any?(p4.hand, fn card -> card == briscola end)
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
      assert 4 == Briscola.Card.score(%Briscola.Card{rank: 10, suit: :cups})
    end

    test "score knights" do
      assert 3 == Briscola.Card.score(%Briscola.Card{rank: 9, suit: :cups})
    end

    test "score jacks" do
      assert 2 == Briscola.Card.score(%Briscola.Card{rank: 8, suit: :cups})
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
          %Briscola.Card{rank: 10, suit: :cups},
          %Briscola.Card{rank: 9, suit: :cups},
          %Briscola.Card{rank: 8, suit: :cups},
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

      # Original deck: 40 cards
      # initial deal: 3 cards for 4 players
      # next deal: 3 cards for 4 players
      # briscola: 1
      assert 40 - (3 * 4 + 4) - 1 == length(game.deck.cards)
    end

    test "fuzz" do
      players = 4
      tricks_to_complete = Integer.floor_div(40, players)

      Enum.each(1..10_000, fn _ ->
        game =
          1..tricks_to_complete
          |> Enum.reduce(Briscola.Game.new(players: players), fn _, game_acc ->
            TestGame.sim_trick(game_acc)
          end)

        assert 0 == length(game.deck.cards)
        assert 40 = Enum.sum_by(game.players, fn player -> length(player.pile) end)
        assert Enum.all?(game.players, fn player -> length(player.hand) == 0 end)

        assert 120 ==
                 Enum.sum_by(game.players, fn player -> Briscola.Player.score(player) end)
      end)
    end
  end
end
