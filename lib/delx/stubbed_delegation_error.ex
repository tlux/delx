defmodule Delx.StubbedDelegationError do
  import Exception, only: [format_mfa: 3]

  defexception [:source, :target, :args]

  @impl true
  def message(%__MODULE__{
        source: {source_mod, source_fun},
        target: {target_mod, target_fun},
        args: args
      }) do
    arity = length(args)

    "Delegation from #{format_mfa(source_mod, source_fun, arity)} " <>
      "to #{format_mfa(target_mod, target_fun, arity)} is stubbed"
  end
end
