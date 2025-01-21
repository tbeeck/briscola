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

  @ranks 0..9


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
  def face(%{"rank" => rank}) do
    case rank do
      0 -> :ace
      7 -> :jack
      8 -> :knight
      9 -> :king
      _ -> :none
    end
  end
end
