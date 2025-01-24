defmodule Briscola.Game do
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

  def new(opts \\ []) do
    player_count = Keyword.get(opts, :players, 2)

    {deck, [briscola]} =
      Deck.new()
      |> Deck.shuffle()
      |> Deck.take(1)

    %Briscola.Game{
      deck: deck,
      players: List.duplicate(%Player{hand: [], pile: []}, player_count),
      briscola: briscola,
      trick: [],
      action_on: Keyword.get(opts, :goes_first, 0)
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

  def score_trick(game) when length(game.trick) != length(game.players) do
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
          best == nil -> card
          card.suit == trump && best.suit != trump -> card
          card.suit == trump && best.suit == trump && Card.score(card) > Card.score(best) -> card
          card.suit == lead && best.suit != trump -> card
          card.suit == lead && best.suit == lead && Card.score(card) > Card.score(best) -> card
          true -> best
        end
      end)

    winning_card_index =
      Enum.reverse(game.trick)
      |> Enum.find_index(&(&1 == winning_card))

    # Work backwards to find index of winning player. Action should be on the original player after a full trick.
    winning_player_index = abs(rem(game.action_on + winning_card_index, length(game.players)))
    {winning_player_index, winning_card}
  end

  def redeal(game) when length(game.trick) == 0 do
    if Enum.all?(game.players, fn p -> length(p.hand) < 3 end) do
      deal_cards(game, 1)
    else
      {:error, :players_have_cards}
    end
  end

  def redeal(game) when length(game.trick) != 0 do
    {:error, :trick_not_scored}
  end

  defp deal_cards(game, n) do
    {new_deck, cards} = Deck.take(game.deck, n * length(game.players))

    new_players =
      Enum.zip(game.players, Enum.chunk_every(cards, n))
      |> Enum.map(fn {player, new_cards} -> %Player{player | hand: new_cards ++ player.hand} end)

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
end
