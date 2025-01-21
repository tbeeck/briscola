defmodule Briscola.Game do
  alias Briscola.Deck

  @hand_size 3

  @type t() :: %Briscola.Game{}
  defstruct [:deck, :players, :hands, :briscola, :trick, :action_on]

  @spec new(keyword()) :: Briscola.Game.t()
  def new(opts \\ []) do
    players = Keyword.get(opts, :players, 2)

    {deck, [briscola]} =
      Deck.new()
      |> Deck.shuffle()
      |> Deck.take(1)

    {deck, hands} = deal(deck, players)

    %Briscola.Game{
      deck: deck,
      players: players,
      hands: hands,
      briscola: briscola,
      trick: [],
      action_on: Keyword.get(opts, :goes_first, 0)
    }
  end

  defp deal(deck, players) do
    {new_deck, cards} = Deck.take(deck, @hand_size * players)
    hands = Enum.chunk_every(cards, @hand_size)
    {new_deck, hands}
  end

  def play(game, card_index) do
    card =
      Enum.at(game.hands, game.action_on, [])
      |> Enum.at(card_index)

    if card do
      hand = Enum.at(game.hands, game.action_on)

      game =
        %Briscola.Game{
          game
          | hands: List.replace_at(game.hands, game.action_on, List.delete(hand, card)),
            trick: [card | game.trick],
            action_on: rem(game.action_on + 1, game.players)
        }

      {:ok, game}
    else
      {:error, :invalid_card}
    end
  end

  def score_trick(game) when length(game.trick) == game.players do
    %Briscola.Game{game | trick: []}
  end

  @spec trump_suit(t()) :: Briscola.Card.suit()
  def trump_suit(game), do: game.briscola.suit

  @spec lead_suit(t()) :: Briscola.Card.suit()
  def lead_suit(game) when length(game.trick) == 0, do: nil
  def lead_suit(game) when length(game.trick) > 0, do: List.last(game.trick).suit
end
