defmodule Delx.Delegator do
  @moduledoc """
  A module that defines the function that a custom delegator module has to
  implement.
  """

  @type mf :: {module, fun :: atom}

  @doc """
  A callback that needs to be implemented by a delegator.
  """
  @callback apply(source :: mf, target :: mf, args :: [any]) :: any
end
