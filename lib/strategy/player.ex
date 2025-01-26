defmodule Briscola.Strategy.Player do
  @moduledoc """
  A briscola strategy implementation that asks a player for a card to play via stdin.
  """
  alias Briscola.Game

  @behaviour Briscola.Strategy
  @impl true
  def choose_card(game, player_index) do
    print_player_state(game)
    ask_choice(game, player_index)
  end

  def ask_choice(%Game{} = game, player_index) do
    hand = Enum.at(game.players, player_index).hand
    IO.puts("Choose a card to play (1-#{length(hand)}):")

    val =
      case IO.gets("> ") |> String.trim() |> Integer.parse() do
        {input, _} when input > 0 and input <= length(hand) ->
          input

        _ ->
          IO.puts("Invalid input, try again!")
          ask_choice(game, player_index)
      end

    card_index = val - 1
    card_index
  end

  defp print_player_state(%Game{} = game) do
    me = Enum.at(game.players, 0)

    briscola_str =
      "\t" <>
        "Briscola is #{game.briscola}"

    hand_str =
      "\t" <>
        case length(me.hand) do
          0 -> "No more cards in hand!"
          _ -> "Hand: #{Enum.join(me.hand, ", ")}"
        end

    trick_str =
      "\t" <>
        case length(game.trick) do
          0 -> "Trick is empty"
          _ -> "Trick: #{Enum.join(game.trick, ", ")}"
        end

    cards_remaining_str = "\t" <> "Draw pile remaining: #{length(game.deck.cards)} + briscola"

    status = [briscola_str, trick_str, cards_remaining_str, hand_str] |> Enum.join("\n")
    IO.puts("Status: \n #{status}")
  end
end
