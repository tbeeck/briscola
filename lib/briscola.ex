defmodule Briscola do
  @moduledoc """
  `Briscola` card game deck & rules.
  """

  @suits [
    :cups,
    :batons,
    :coins,
    :swords
  ]
  @doc """
    Returns a list of the suits of the cards.
  """
  def suits(), do: @suits

  @ranks 1..13
  @doc """
    Returns a range rempresenting the ranks of the cards.
  """
  def ranks(), do: @ranks

  defmodule Card do
    @type t() :: %Card{}
    @type suit() :: :cups | :batons | :coins | :swords
    @type rank() :: 1..13
    defstruct [:suit, :rank]

    @spec score(Card.t()) :: integer()
    def score(%Card{rank: rank}) do
      case rank do
        1 -> 11
        3 -> 10
        13 -> 4
        12 -> 3
        11 -> 2
        _ -> 0
      end
    end

    @doc """
      Returns the face of a card.
    """
    @spec face(Card.t()) :: :ace | :jack | :king | :knight | :none
    def face(%Card{:rank => rank}) do
      case rank do
        1 -> :ace
        11 -> :jack
        12 -> :knight
        13 -> :king
        _ -> :none
      end
    end
  end

  defmodule Deck do
    @type t() :: %Deck{}
    defstruct [:cards]

    @doc """
      Create a new deck of cards.
    """
    @spec new() :: Deck.t()
    def new() do
      cards =
        for suit <- Briscola.suits(),
            rank <- Briscola.ranks(),
            do: %Card{suit: suit, rank: rank}

      %Deck{cards: cards}
    end

    @doc """
      Shuffle a deck of cards.
    """
    def shuffle(%Deck{cards: cards}) do
      %Deck{cards: Enum.shuffle(cards)}
    end

    @doc """
      Take a number of cards from the top of the deck.
    """
    @spec take(Deck.t(), integer()) :: {Deck.t(), [Card.t()]}
    def take(%Deck{cards: cards} = deck, n) do
      {taken, new_deck} = Enum.split(cards, n)
      {%Deck{deck | cards: new_deck}, taken}
    end
  end
end
