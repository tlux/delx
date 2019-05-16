defmodule Delx.Defdel do
  @moduledoc false

  defmacro defdel(funs, opts) do
    funs = Macro.escape(funs, unquote: true)

    quote bind_quoted: [funs: funs, opts: opts] do
      target =
        opts[:to] || raise ArgumentError, "expected to: to be given as argument"

      for fun <- List.wrap(funs) do
        {name, args, as, as_args} = Kernel.Utils.defdelegate(fun, opts)

        @doc delegate_to: {target, as, length(as_args)}
        def unquote(name)(unquote_splicing(args)) do
          __MODULE__.__delegator__().apply(
            {unquote(__MODULE__), unquote(name)},
            {unquote(target), unquote(as)},
            unquote(as_args)
          )
        end
      end
    end
  end
end
