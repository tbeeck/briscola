defmodule BriscolaTest.GameFixture do
  alias Briscola.Player
  alias Briscola.Card
  alias Briscola.Deck
  alias Briscola.Game

  def new(opts \\ []) do
    player_count = Keyword.get(opts, :players, 2)

    %Briscola.Game{
      deck: Briscola.Deck.new() |> Briscola.Deck.shuffle(),
      players: Enum.map(1..player_count, fn _ -> Briscola.Player.new() end),
      briscola: nil,
      trick: [],
      action_on: 0
    }
  end

  @spec briscola(Game.t(), Card.t()) :: Game.t()
  def briscola(game, card) do
    %Briscola.Game{
      game
      | deck: pop_card(game.deck, card),
        briscola: card
    }
  end

  @spec hand(Game.t(), integer(), [Card.t()]) :: Game.t()
  def hand(game, player_index, hand) do
    %Briscola.Game{
      game
      | players:
          List.update_at(game.players, player_index, fn player ->
            %Briscola.Player{player | hand: hand}
          end),
        deck: pop_cards(game.deck, hand)
    }
  end

  @spec fill_hands(Game.t(), integer()) :: Game.t()
  def fill_hands(game, card_count) do
    # Top up hands to card_count using top of deck
    {players, deck} =
      Enum.reduce(game.players, {[], game.deck}, fn player, {players_acc, deck_acc} ->
        required_cards = max(0, card_count - length(player.hand))
        {deck_acc, cards} = Deck.take(deck_acc, required_cards)
        # Append to front to keep original order
        {players_acc ++ [%Player{player | hand: cards ++ player.hand}], deck_acc}
      end)

    %Game{game | players: players, deck: deck}
  end

  @spec trick(Game.t(), [Card.t()]) :: Game.t()
  def trick(game, trick) do
    %Briscola.Game{
      game
      | trick: trick,
        deck: pop_cards(game.deck, trick)
    }
  end

  @spec action_on(Game.t(), integer()) :: Game.t()
  def action_on(game, action) do
    %Briscola.Game{
      game
      | action_on: action
    }
  end

  @spec top_cards(Game.t(), [Card.t()]) :: Game.t()
  def top_cards(game, cards) do
    rem_deck = pop_cards(game.deck, cards)
    new_deck = %Deck{cards: cards ++ rem_deck.cards}

    %Briscola.Game{
      game
      | deck: new_deck
    }
  end

  @spec pop_cards(Deck.t(), [Card.t()]) :: Deck.t()
  defp pop_cards(deck, cards) do
    Enum.reduce(cards, deck, fn card, acc -> pop_card(acc, card) end)
  end

  @spec pop_card(Deck.t(), Card.t()) :: Deck.t()
  defp pop_card(deck, card) do
    %Deck{
      cards: Enum.reject(deck.cards, fn c -> c == card end)
    }
  end

  @spec sim_trick(Game.t()) :: Game.t()
  def sim_trick(game) do
    {:ok, game, _} =
      Enum.reduce(1..length(game.players), game, fn _, game_acc ->
        {:ok, new_game} = Game.play(game_acc, 0)
        new_game
      end)
      |> Game.score_trick()

    case length(game.deck.cards) do
      0 -> game
      _ -> Game.redeal(game)
    end
  end

  def deck(game, cards) do
    %Briscola.Game{
      game
      | deck: %Deck{cards: cards}
    }
  end
end
