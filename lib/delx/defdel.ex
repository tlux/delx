defmodule Delx.Defdel do
  @moduledoc """
  A module defining a macro to define delegate functions.
  """

  @doc """
  You can delegate functions calls to another module by using the `Delx`
  module and calling the `defdel/2` macro in the module body. It has
  the same API as Elixir's own `Kernel.defdelegate/2` macro.

  ## Example

  Before calling `defdel/2`, you need to use `Delx`.

      iex> defmodule Greeter do
      ...>   use Delx, otp_app: :greeter

      ...>   defdel hello(name), to: Greeter.StringGreeter, as: :welcome
      ...> end
  """
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
