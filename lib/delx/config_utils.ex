defmodule Delx.ConfigUtils do
  @moduledoc false

  @spec get_delegator(Keyword.t()) :: module
  def get_delegator(config) do
    case Keyword.fetch(config, :mock) do
      {:ok, true} -> Delx.Delegator.Mock
      _ -> Keyword.get(config, :delegator, Delx.Delegator.Common)
    end
  end
end
