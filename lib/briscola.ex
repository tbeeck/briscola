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
  end

  @doc """
    Shuffle a deck of cards.
  """
  def shuffle(%Deck{cards: cards}) do
    %Deck{cards: Enum.shuffle(cards)}
  end

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
