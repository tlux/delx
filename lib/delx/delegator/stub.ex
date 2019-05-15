defmodule Delx.Delegator.Stub do
  @moduledoc """
  This module is a custom delegator that does not actually delegate but echoes
  a tuple containing the module, function and args which the original function
  was called with. This is useful when you want to stub all delegations but not
  actually call the delegation target.
  """

  @behaviour Delx.Delegator

  @impl true
  def apply(source, target, args) do
    result = {:delx, source, target, args}
    send(self(), result)
    result
  end
end
