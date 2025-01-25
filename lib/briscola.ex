defmodule Briscola do
  @moduledoc """
  `Briscola` card game concepts and rules.
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
    @moduledoc """
    Struct for a card in the game of Briscola.
    https://en.m.wikipedia.org/wiki/Italian_playing_cards
    """

    @typedoc """
    Suit of a card.
    """
    @type suit() :: :cups | :batons | :coins | :swords

    @typedoc """
    Valid ranks for a card.
    """
    @type rank() :: 1..13

    defstruct [:suit, :rank]

    @type t() :: %__MODULE__{
            suit: suit(),
            rank: rank()
          }

    @doc """
    Returns the score of a card, used for calculating a player's score.
    """
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
    Returns the strength of a card, used to determine a trick winner.
    """
    def strength(%Card{rank: rank} = card) do
      case score(card) do
        0 -> rank
        value -> value
      end
    end
  end

  defmodule Deck do
    @moduledoc """
    Struct for a deck of cards in the game of Briscola.
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
    The pile of won cards are used for scoring.
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
  end
end
