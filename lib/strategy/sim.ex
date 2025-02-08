defmodule Briscola.Strategy.Simulator do
  @moduledoc """
  A module for simulating games of Briscola using different strategies.
  """

  alias Briscola.Game
  alias Briscola.Strategy.Simulator

  defstruct [:game, :strategies, :log, :on_message]

  @type t() :: %__MODULE__{
          game: Game.t(),
          strategies: list(module()),
          log: list(log_message()),
          on_message: (log_message() -> any())
        }

  @type log_message() ::
          {:game_over, [Briscola.Player.t()]}
          | {:trick_winner, integer()}
          | {:player_turn, integer(), Briscola.Card.t()}
          | {:start, Briscola.Game.t()}

  @type new_options() :: [on_message: (Game.t(), log_message() -> any())]

  @doc """
  Create a new simulator with a game and a list of strategies.
  Player 0 will use the first strategy, player 1 the second, and so on.
  """
  @spec new([module()], new_options()) :: t()
  def new(game, strategies, opts \\ [])

  def new(game, strategies, _opts) when length(game.players) != length(strategies) do
    raise ArgumentError, "Number of strategies must match the number of players"
  end

  def new(game, strategies, opts) do
    message_handler =
      Keyword.get(opts, :on_message, Keyword.get(opts, :on_message, fn _, _ -> nil end))

    %Simulator{
      game: game,
      strategies: strategies,
      log: [{:start, game}],
      on_message: message_handler
    }
  end

  @doc """
  Simulate until the game is over.
  """
  def run(sim) do
    case List.first(sim.log) do
      {:game_over, _} -> sim
      _ -> run(sim_turn(sim))
    end
  end

  @doc """
  Simulate a single turn in the game.
  That may mean playing a card, scoring a trick then redealing, or ending the game.
  """
  def sim_turn(%Simulator{} = sim) do
    game = sim.game
    strategies = sim.strategies
    log = sim.log

    {game, event} =
      cond do
        Game.game_over?(game) ->
          {game, {:game_over, Game.leaders(game)}}

        Game.should_score_trick?(game) ->
          {:ok, game, trick_winner} = Game.score_trick(game)
          event = {:trick_winner, trick_winner}

          game =
            case Game.redeal(game) do
              {:error, :not_enough_cards} -> game
              g -> g
            end

          {game, event}

        # Play the card chosen by the strategy
        true ->
          player_index = game.action_on
          strategy = Enum.at(strategies, player_index)
          card_index = strategy.choose_card(game, player_index)
          played_card = Enum.at(Enum.at(game.players, player_index).hand, card_index)

          event =
            {:player_turn, player_index, played_card}

          {:ok, game} = Game.play(game, card_index)
          {game, event}
      end

    log = [event | log]
    sim.on_message.(game, event)

    case event do
      {:game_over, _} ->
        %Simulator{sim | log: log}

      _ ->
        %Simulator{sim | game: game, log: log}
    end
  end
end
