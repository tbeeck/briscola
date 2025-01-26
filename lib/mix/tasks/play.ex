defmodule Mix.Tasks.Briscola.Play do
  @moduledoc """
  A mix task to play Briscola.

  This task will start a game of Briscola and allow the player to play against AI.

  Enter the number of the card in your hand that you want to play when prompted.
  (1 for the first card, 2 for the second, etc.)

  Accepts the following arguments:
    * `--players` or `-p`: The number of players in the game. Default is 2.
    * `--strategies` or `-s`: A comma-separated list of AI strategies to use.
      The first strategy will be used by the player, the rest by AI.
      By default AI will select random cards.
      The strategy name is the module name, i.e. "Briscola.Strategy.Random".
  """
  use Mix.Task

  alias Briscola.Game
  alias Briscola.Strategy.Simulator

  @shortdoc "Play Briscola"
  def run(args) do
    IO.puts("Welcome to Briscola!")

    {opts, _, _} =
      OptionParser.parse(args,
        switches: [players: :integer, strategies: :string],
        aliases: [p: :players, s: :strategies]
      )

    player_count = Keyword.get(opts, :players, 4)

    ai_strategies =
      case Keyword.get(opts, :strategies) do
        nil ->
          List.duplicate(Briscola.Strategy.Random, player_count - 1)

        s ->
          String.split(s, ",")
          |> Enum.map(&("Elixir." <> &1))
          |> Enum.map(&String.to_existing_atom/1)
      end

    # Player zero uses the player strategy
    strategies = [Briscola.Strategy.Player | ai_strategies]
    game = Briscola.Game.new(players: player_count)

    sim =
      Simulator.new(game, strategies, on_message: &handle_game_message/2)
      |> Simulator.run()

    print_winner(sim.game)
  end

  defp handle_game_message(_game, msg) do
    Process.sleep(300)

    case msg do
      {:game_over, _} -> IO.puts("Game over!")
      {:trick_winner, winner} -> IO.puts("Player #{winner} won the trick! Next round.\n")
      {:player_turn, player, card} -> IO.puts("Player #{player} played #{card}")
    end
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
end
