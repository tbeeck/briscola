defmodule Briscola do
  @moduledoc """
  Module for the card game Briscola.
  Contains modules for cards, decks, players, the game itself,
  as well as a behavior for implementing game strategies.
  """

  @suits [
    :cups,
    :coins,
    :swords,
    :batons
  ]
  @doc """
  Returns a list of the valid suits for briscola cards.
  """
  def suits(), do: @suits

  @ranks 1..10
  @doc """
    Returns a range representing the ranks of the cards.
  """
  def ranks(), do: @ranks

  defmodule Card do
    @moduledoc """
    Struct for a card in the game of Briscola.
    https://en.m.wikipedia.org/wiki/Italian_playing_cards
    """

    @typedoc """
    The suit of a card.
    """
    @type suit() :: :cups | :coins | :swords | :batons

    @typedoc """
    Possible ranks for a card in a stripped Italian deck.
    """
    @type rank() :: 1..10

    defstruct [:suit, :rank]

    @type t() :: %__MODULE__{
            suit: suit(),
            rank: rank()
          }

    @doc """
    Returns the point value of a card
    """
    @spec score(Card.t()) :: integer()
    def score(%Card{rank: rank}) do
      case rank do
        1 -> 11
        3 -> 10
        10 -> 4
        9 -> 3
        8 -> 2
        _ -> 0
      end
    end

    @doc """
    Returns the strength of a card, used to determine a trick winner.
    """
    def strength(%Card{rank: rank} = card) do
      # Any scoring card is stronger than a non-scoring card
      # Offset the score value by 10 to make scoring cards always stronger
      case score(card) do
        0 -> rank
        value -> value + 10
      end
    end
  end

  defmodule Deck do
    @moduledoc """
    Struct representing a deck of cards.
    """
    defstruct [:cards]

    @type t() :: %__MODULE__{
            cards: [Card.t()]
          }

    @doc """
    Create a new deck of cards, not shuffled.
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
    The top of the deck is the beginning of the list of cards.
    """
    @spec take(Deck.t(), integer()) :: {Deck.t(), [Card.t()]}
    def take(%Deck{cards: cards} = deck, n) do
      {taken, new_deck} = Enum.split(cards, n)
      {%Deck{deck | cards: new_deck}, taken}
    end
  end

  defmodule Player do
    @moduledoc """
    Struct for a player in the game of Briscola.
    Players have a hand of playing cards and a pile of won cards.
    The pile of won cards is used for scoring.
    """
    defstruct [:hand, :pile]

    @type t() :: %__MODULE__{
            hand: [Card.t()],
            pile: [Card.t()]
          }

    @doc """
      Create a new player.
    """
    @spec new() :: Player.t()
    def new() do
      %Player{hand: [], pile: []}
    end

    @doc """
    Calculate the score of a player.
    The score is the sum of the scores of the cards in the player's pile.
    """
    @spec score(Player.t()) :: integer()
    def score(%Player{pile: pile}) do
      Enum.sum_by(pile, &Card.score(&1))
    end

    @doc """
    Remove a specific card from a player's hand.
    """
    @spec remove_from_hand(Player.t(), Card.t()) :: t()
    def remove_from_hand(player, card) do
      hand = Enum.reject(player.hand, &(&1 == card))
      %Player{player | hand: hand}
    end

    @doc """
    Add cards to a player's score pile.
    """
    @spec take_trick(Player.t(), [Card.t()]) :: t()
    def take_trick(player, cards) do
      %Player{player | pile: cards ++ player.pile}
    end
  end
end

defimpl String.Chars, for: Briscola.Card do
  def to_string(card) do
    "(#{card_title(card)}, #{card.suit})"
  end

  defp card_title(%Briscola.Card{rank: rank}) do
    case rank do
      1 -> "ace"
      8 -> "jack"
      9 -> "knight"
      10 -> "king"
      _ -> Integer.to_string(rank)
    end
  end
end
