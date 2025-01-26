defmodule BriscolaTest.Simulator do
  use ExUnit.Case

  alias Briscola.Game
  alias Briscola.Strategy
  alias Briscola.Strategy.Simulator

  describe "Simulator" do
    test "simulates a game with two players" do
      game = Game.new(players: 2)
      strategies = [Strategy.Random, Strategy.Random]
      sim = Simulator.new(game, strategies)

      sim = Simulator.run(sim)

      assert Game.game_over?(sim.game)
    end

    test "simulates a game with four players" do
      game = Game.new(players: 4)
      strategies = List.duplicate(Strategy.Random, 4)
      sim = Simulator.new(game, strategies)

      sim = Simulator.run(sim)

      assert Game.game_over?(sim.game)
    end

    test "last log message is game over" do
      game = Game.new(players: 2)
      strategies = [Strategy.Random, Strategy.Random]
      sim = Simulator.new(game, strategies)

      sim = Simulator.run(sim)

      # End of the log is the beginning
      assert :game_over == elem(List.first(sim.log), 0)
    end
  end
end
