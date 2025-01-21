defmodule Briscola.Game do
  alias Briscola.Deck

  @type t() :: %Briscola.Game{}
  defstruct [:deck, :players, :hands, :briscola, :trick, :turn]

  @spec new(keyword()) :: Briscola.Game.t()
  def new(opts \\ []) do
    players = Keyword.get(opts, :player_count, 2)
    hands = Enum.map(1..players, fn _ -> [] end)

    {deck, [briscola]} =
      Deck.new()
      |> Deck.shuffle()
      |> Deck.take(1)

    trick = []

    %Briscola.Game{
      deck: deck,
      players: players,
      hands: hands,
      briscola: briscola,
      trick: trick
    }
  end

  @spec trump_suit(t()) :: Briscola.Card.suit()
  def trump_suit(game), do: game.briscola.suit

  @spec lead_suit(t()) :: Briscola.Card.suit()
  def lead_suit(game) when length(game.trick) == 0, do: nil
  def lead_suit(game) when length(game.trick) > 0, do: Enum.at(game.trick, 0).suit
end
