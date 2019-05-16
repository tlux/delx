defmodule EchoDelegator do
  @behaviour Delx.Delegator

  @impl true
  def apply(source, target, args) do
    {:delx, {source, target, args}}
  end
end
