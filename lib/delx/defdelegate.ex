defmodule Delx.Defdelegate do
  @moduledoc """
  A module defining a macro to define delegate functions.
  """

  @doc """
  You can delegate functions calls to another module by using the `Delx`
  module and calling the `defdelegate/2` macro in the module body. It has
  the same API as Elixir's own `Kernel.defdelegate/2` macro.

  ## Example

  Before calling `defdelegate/2`, you need to use `Delx`.

      iex> defmodule Greeter do
      ...>   use Delx, otp_app: :greeter

      ...>   defdelegate hello(name), to: Greeter.StringGreeter, as: :welcome
      ...> end
  """
  defmacro defdelegate(funs, opts) do
    funs = Macro.escape(funs, unquote: true)

    quote bind_quoted: [funs: funs, opts: opts] do
      target =
        opts[:to] || raise ArgumentError, "expected to: to be given as argument"

      for fun <- List.wrap(funs) do
        {name, args, as, as_args} = Kernel.Utils.defdelegate(fun, opts)

        # Dialyzer may possibly complain about "No local return". So we tell him
        # to stop as we're only delegating here.
        @dialyzer {:nowarn_function, [{name, length(as_args)}]}

        @doc delegate_to: {target, as, length(as_args)}
        def unquote(name)(unquote_splicing(args)) do
          @delegator.apply(
            {unquote(__MODULE__), unquote(name)},
            {unquote(target), unquote(as)},
            unquote(as_args)
          )
        end
      end
    end
  end
end
