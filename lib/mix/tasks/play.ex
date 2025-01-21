defmodule Mix.Tasks.Briscola.Play do
  @moduledoc """
  A mix task to play Briscola.
  """
  use Mix.Task

  @shortdoc "Play Briscola"
  def run(_args) do
    IO.puts("Welcome to Briscola!")
    game = Briscola.Game.new()
    IO.inspect(game)
    loop(game)
  end

  defp loop(game) do
    input = IO.gets("> ") |> String.trim()

    case input do
      "exit" -> :ok
      _ -> loop(game)
    end
  end
end
