defmodule Mix.Tasks.Briscola.Play do
  @moduledoc """
  A mix task to play Briscola.
  """
  use Mix.Task

  alias Briscola.Game

  @shortdoc "Play Briscola"
  def run(_args) do
    IO.puts("Welcome to Briscola!")
    game = Briscola.Game.new(players: 4)
    next_turn(game)
  end

  defp next_turn(%Game{} = game) do
    cond do
      game_over?(game) ->
        print_winner(game)

      should_score_trick?(game) ->
        {:ok, game, trick_winner} = Game.score_trick(game)
        IO.puts("Player #{trick_winner} won the trick!")

        case Game.redeal(game) do
          {:error, :not_enough_cards} -> game
          g -> g
        end
        |> next_turn()

      player_turn?(game) ->
        next_turn(do_player_turn(game))

      # AI's turn
      true ->
        next_turn(do_ai_turn(game))
    end
  end

  defp should_score_trick?(%Game{} = game) do
    length(game.trick) == length(game.players)
  end

  defp do_ai_turn(%Game{} = game) do
    card_to_play = Enum.at(Enum.at(game.players, game.action_on).hand, 0)
    IO.puts("Player #{game.action_on} plays #{card_to_play}")
    {:ok, game} = Game.play(game, 0)
    game
  end

  defp do_player_turn(%Game{} = game) do
    print_player_state(game)

    input =
      try do
        IO.gets("> ") |> String.trim() |> String.to_integer()
      catch
        _ -> -1
      end

    case Game.play(game, input) do
      {:error, _} ->
        IO.puts("Invalid card, try again!")
        do_player_turn(game)

      {:ok, new_game} ->
        card_to_play = Enum.at(Enum.at(new_game.players, new_game.action_on).hand, 0)
        IO.puts("You play #{card_to_play}")
        new_game
    end
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
          0 -> "Trick is empty! "
          _ -> "Trick: #{Enum.join(game.trick, ", ")}"
        end

    IO.puts("Status: \n " <> briscola_str <> "\n" <> hand_str <> "\n" <> trick_str)
  end

  defp print_winner(%Game{} = game) do
    winner =
      Enum.with_index(game.players)
      |> Enum.max_by(fn {player, _index} -> Briscola.Player.score(player) end)
      |> elem(1)

    final =
      case winner do
        0 -> "You win! Good job!"
        i -> "Player #{i} won. Better luck next time!"
      end

    IO.puts(final)
  end

  defp game_over?(%Game{} = game) do
    length(game.deck.cards) == 0 and Enum.all?(game.players, fn p -> length(p.hand) == 0 end)
  end

  # Player is always player 0
  defp player_turn?(game), do: game.action_on == 0
end
