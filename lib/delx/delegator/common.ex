defmodule Delx.Delegator.Common do
  @moduledoc """
  This module is the delegator that is used by default.
  """

  @behaviour Delx.Delegator

  @impl true
  def apply(_source, {module, fun}, args) do
    Kernel.apply(module, fun, args)
  end
end
