defmodule Briscola.Game do
  alias Briscola.Deck

  @hand_size 3

  @type t() :: %Briscola.Game{}
  defstruct [:deck, :players, :hands, :briscola, :trick, :action_on]

  @spec new(keyword()) :: Briscola.Game.t()
  def new(opts \\ []) do
    players = Keyword.get(opts, :players, 2)
    hands = Enum.map(1..players, fn _ -> [] end)

    {deck, [briscola]} =
      Deck.new()
      |> Deck.shuffle()
      |> Deck.take(1)

    {deck, hands} = deal(deck, hands)

    %Briscola.Game{
      deck: deck,
      players: players,
      hands: hands,
      briscola: briscola,
      trick: [],
      action_on: Keyword.get(opts, :goes_first, 0)
    }
  end

  defp deal(deck, hands) do
    {new_deck, cards} = Deck.take(deck, @hand_size * length(hands))
    hands = Enum.chunk_every(cards, @hand_size)
    {new_deck, hands}
  end

  @spec trump_suit(t()) :: Briscola.Card.suit()
  def trump_suit(game), do: game.briscola.suit

  @spec lead_suit(t()) :: Briscola.Card.suit()
  def lead_suit(game) when length(game.trick) == 0, do: nil
  def lead_suit(game) when length(game.trick) > 0, do: Enum.at(game.trick, 0).suit
end
