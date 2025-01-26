defmodule Briscola.Strategy do
  @moduledoc """
  A protocol for defining strategies for playing Briscola.
  """

  alias Briscola.Game

  @doc """
  Given a game state and a player index, choose a card for that player to play.
  """
  @callback choose_card(game :: Game.t(), player_index :: non_neg_integer()) :: 0..2
end
