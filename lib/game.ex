defmodule Briscola.Game do
  @moduledoc """
  `Briscola.Game` module implements a struct that represents a game state,
  and functions to manipulate the game state according to the stages of the game.
  """

  alias Briscola.Game
  alias Briscola.Card
  alias Briscola.Deck
  alias Briscola.Player

  @hand_size 3

  defstruct [:deck, :players, :briscola, :trick, :action_on]

  @type t() :: %__MODULE__{
          deck: Deck.t(),
          players: [Player.t()],
          briscola: Card.t(),
          trick: [Card.t()],
          action_on: integer()
        }

  @typedoc """
    Options for creating a new game.
    Players is the number of players, can be 2 or 4.
    Goes first is the index of the player who goes first (zero indexed)
  """
  @type new_game_options() :: [players: 2 | 4, goes_first: non_neg_integer()]

  @doc """
  Create a new game of Briscola.
  """
  @spec new(new_game_options()) :: t()
  def new(opts \\ []) do
    player_count =
      case Keyword.get(opts, :players, 2) do
        i when i in [2, 4] -> i
        i -> raise ArgumentError, "Invalid number of players: #{i}"
      end

    goes_first =
      case Keyword.get(opts, :goes_first, 0) do
        i when i < 0 or i >= player_count -> raise ArgumentError, "Invalid first player: #{i}"
        i -> i
      end

    {deck, [briscola]} =
      Deck.new()
      |> Deck.shuffle()
      |> Deck.take(1)

    %Briscola.Game{
      deck: deck,
      players: List.duplicate(%Player{hand: [], pile: []}, player_count),
      briscola: briscola,
      trick: [],
      action_on: goes_first
    }
    |> deal_cards(@hand_size)
  end

  def play(game, _) when length(game.trick) == length(game.players) do
    {:error, :trick_over}
  end

  def play(game, card_index) when is_integer(card_index) do
    card =
      Enum.at(game.players, game.action_on).hand
      |> Enum.at(card_index)

    if card do
      play(game, card)
    else
      {:error, :invalid_card}
    end
  end

  def play(game, %Card{} = card) do
    if card in Enum.at(game.players, game.action_on).hand do
      new_players =
        List.update_at(game.players, game.action_on, &Player.remove_from_hand(&1, card))

      game =
        %Briscola.Game{
          game
          | trick: [card | game.trick],
            action_on: rem(game.action_on + 1, length(game.players)),
            players: new_players
        }

      {:ok, game}
    else
      {:error, :invalid_card}
    end
  end

  @doc """
  Score the current trick, moving the cards to the winning player's pile.
  Also clears the trick and sets the action to the winning player.
  """
  @spec score_trick(t()) :: {:ok, t(), non_neg_integer()} | {:error, :trick_not_over}
  def score_trick(game)

  def score_trick(%Game{} = game) when length(game.trick) != length(game.players) do
    {:error, :trick_not_over}
  end

  def score_trick(game) do
    {winning_player, _winning_card} = trick_winner(game)

    game =
      %Briscola.Game{
        game
        | players: List.update_at(game.players, winning_player, &take_trick(&1, game.trick)),
          trick: [],
          action_on: winning_player
      }

    {:ok, game, winning_player}
  end

  defp trick_winner(game) do
    trump = trump_suit(game)
    lead = lead_suit(game)

    winning_card =
      Enum.reduce(game.trick, nil, fn card, best ->
        cond do
          best == nil ->
            card

          card.suit == trump && best.suit != trump ->
            card

          card.suit == lead && best.suit != trump && best.suit != lead ->
            card

          card.suit == trump && best.suit == trump && Card.strength(card) > Card.strength(best) ->
            card

          card.suit == lead && best.suit == lead && Card.strength(card) > Card.strength(best) ->
            card

          true ->
            best
        end
      end)

    winning_card_index =
      Enum.reverse(game.trick)
      |> Enum.find_index(&(&1 == winning_card))

    # Work backwards to find index of winning player. Action should be on the original player after a full trick.
    winning_player_index = abs(rem(game.action_on + winning_card_index, length(game.players)))
    {winning_player_index, winning_card}
  end

  @doc """
  Redistribute one card to each player, call this after scoring a trick.

  Since the last few turns of the game don't have enough cards to deal to all players,
  it's normal to get back {:error, :not_enough_cards} on the last few turns.
  """
  @spec redeal(t()) :: t() | {:error, :trick_not_scored | :not_enough_cards}
  def redeal(game)

  def redeal(game) when length(game.trick) != 0 do
    {:error, :trick_not_scored}
  end

  def redeal(game) when length(game.deck.cards) + 1 < length(game.players) do
    {:error, :not_enough_cards}
  end

  # Deal the briscola to the last player
  def redeal(game) when length(game.deck.cards) + 1 == length(game.players) do
    game = %Briscola.Game{
      game
      | deck: %Deck{game.deck | cards: game.deck.cards ++ [game.briscola]}
    }

    deal_cards(game, 1)
  end

  def redeal(game) when length(game.trick) == 0 do
    if Enum.all?(game.players, fn p -> length(p.hand) < 3 end) do
      deal_cards(game, 1)
    else
      {:error, :players_have_cards}
    end
  end

  defp deal_cards(%Game{} = game, n) do
    {new_deck, cards} = Deck.take(game.deck, n * length(game.players))

    # "Rotate" the list so the winner of the last trick gets the first
    # batch of cards, and the player fursthest from the action gets the last.
    # This ensures the last player gets the briscola on the last dealing.
    new_players =
      Enum.split(game.players, game.action_on)
      |> Tuple.to_list()
      |> Enum.reverse()
      |> Enum.concat()
      |> Enum.zip(Enum.chunk_every(cards, n))
      |> Enum.map(fn {player, new_cards} ->
        %Player{player | hand: player.hand ++ new_cards}
      end)
      # Rotate the list back so players are in their original positions.
      |> Enum.split(length(game.players) - game.action_on)
      |> Tuple.to_list()
      |> Enum.reverse()
      |> Enum.concat()

    %Game{game | deck: new_deck, players: new_players}
  end

  def take_trick(player, trick) do
    %Player{player | pile: player.pile ++ trick}
  end

  @spec trump_suit(t()) :: Card.suit()
  def trump_suit(game), do: game.briscola.suit

  @spec lead_suit(t()) :: Card.suit()
  def lead_suit(game) when length(game.trick) == 0, do: nil
  def lead_suit(game) when length(game.trick) > 0, do: List.last(game.trick).suit

  @doc """
  Check if the trick is over, i.e. all players have played a card.
  """
  @spec should_score_trick?(t()) :: boolean()
  def should_score_trick?(%Game{} = game) do
    length(game.trick) == length(game.players)
  end

  @doc """
  Check if the game is over, i.e. the deck is empty and all players have no cards.
  """
  @spec game_over?(t()) :: boolean()
  def game_over?(%Game{} = game) do
    length(game.deck.cards) == 0 and Enum.all?(game.players, fn p -> length(p.hand) == 0 end)
  end

  @doc """
  Return players in order of highest score to lowest.
  """
  @spec leaders(t()) :: [Player.t()]
  def leaders(%Game{} = game) do
    Enum.with_index(game.players)
    |> Enum.sort_by(fn {player, _idx} -> Player.score(player) end, &>=/2)
    |> Enum.map(&elem(&1, 1))
  end
end
