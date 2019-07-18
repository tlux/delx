defmodule Delx.Delegator.Mock do
  @moduledoc """
  This module is a custom delegator that does not actually delegate but instead
  raises an exception containing the delegation details. This is useful when you
  want to mock all delegations but not actually call the delegation target.
  This delegator must be used to make `Delx.TestAssertions` work.
  """

  @behaviour Delx.Delegator

  alias Delx.MockedDelegationError

  @impl true
  def apply(source, target, args) do
    raise MockedDelegationError, source: source, target: target, args: args
  end
end
