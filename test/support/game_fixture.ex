defmodule Briscola.GameFixture do
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
end
