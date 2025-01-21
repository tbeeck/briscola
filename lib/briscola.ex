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

  @ranks 1..10


  defmodule Card do
    @type t() :: %Card{}
    defstruct [:suit, :rank]
  end

  defmodule Deck do
    @type t() :: %Deck{}
    defstruct [:cards]
  end

  @spec new_deck() :: Deck.t()
  def new_deck() do
    cards =
      for suit <- @suits,
          rank <- @ranks,
          do: %Card{suit: suit, rank: rank}

    %Deck{cards: cards}
  end

  @spec face(Card.t()) :: :ace | :jack | :king | :knight | :none
  def face(%Card{:rank => rank}) do
    case rank do
      1 -> :ace
      8 -> :jack
      9 -> :knight
      10 -> :king
      _ -> :none
    end
  end
end
