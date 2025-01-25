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
      Returns the score of a card.
      This score is used for comparing what card wins a trick,
      and for calculating the player's final score.
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
  end

  defmodule Deck do
    defstruct [:cards]

    @type t() :: %__MODULE__{
            cards: [Card.t()]
          }

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

  defmodule Player do
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

    @spec score(Player.t()) :: integer()
    def score(%Player{pile: pile}) do
      Enum.sum_by(pile, &Card.score(&1))
    end

    @spec remove_from_hand(Player.t(), Card.t()) :: t()
    def remove_from_hand(player, card) do
      hand = Enum.reject(player.hand, &(&1 == card))
      %Player{player | hand: hand}
    end
  end
end
