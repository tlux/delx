defmodule Delx.Delegator do
  @moduledoc """
  A module that defines the function that a custom delegator module has to
  implement.

  A delegator only contains an `c:apply/3` function that takes the delegation
  source as first argument, delegation target as second argument and the
  forwarded arguments list as third argument.
  """

  @typedoc """
  A tuple that contains a module and function name as atom.
  """
  @type mf :: {module, fun :: atom}

  @doc """
  A callback that needs to be implemented by a delegator.
  """
  @callback apply(source :: mf, target :: mf, args :: [any]) :: any
end
