defmodule Delx do
  @moduledoc """
  An Elixir library to make function delegation testable.

  ## Usage

  Let's say you have the following module.

      iex> defmodule Greeter.StringGreeter do
      ...>   def hello(name) do
      ...>     "Hello, \#{name}!"
      ...>   end
      ...> end

  You can delegate functions calls to another module by importing the `Delx`
  module and using the `defdel/2` macro. It has the same syntax and options as
  Elixir's own `Kernel.defdelegate/2` macro.

      iex> defmodule Greeter do
      ...>   import Delx

      ...>   defdel hello(name), to: Greeter.StringGreeter
      ...> end

      iex> DelegatingModule.hello("Tobi")
      "Hello, Tobi!"

  ## Testing

  One great benefit of Delx is that you can test delegation without invoking
  the actual implementation of the delegation target, thus eliminating all side
  effects.

  ### With the Stub Delegator

  Delx brings it's own delegator stub.

  You can activate it for your test environment by putting the following line in
  your `config/test.exs`:

      config :delx, :stub, true
      # or
      config :delx, :delegator, Delx.Delegator.Stub

  Then in your tests, you can assert whether delegation took place:

      defmodule GreeterTest do
        use ExUnit.Case

        import Delx.TestAssertions

        describe "hello/1" do
          test "delegate to Greeter.StringGreeter" do
            assert_delegate {Greeter, :hello, 1}, to: Greeter.StringGreeter
          end
        end
      end

  ### With Mox

  If you are already using [Mox](https://hexdocs.pm/mox) in your application
  it's straightforward to test delegates.

  Add the mock for the `Delx.Delegator` behavior to your `test/test_helper.exs`:

      Mox.defmock(Delx.Delegator.Mock, for: Delx.Delegator)

  Then, in your `config/test.exs` you have to set the mock as delegator module:

      config :delx, :delegator, Delx.Delegator.Mock

  Now you are able to `expect` calls to delegated functions:

      defmodule GreeterTest do
        use ExUnit.Case

        import Mox

        setup :verify_on_exit!

        describe "hello/1" do
          test "delegate to Greeter.StringGreeter" do
            expect(Delx.Delegator.Mock, :apply, fn Greeter.StringGreeter,
                                                   :hello,
                                                   ["Tobi"] ->
              :ok
            end)

            Greeter.hello("Tobi")
          end
        end
      end
  """

  @doc """
  The module that is used to control delegation. Has to implement the
  `Delx.Delegator` behavior.
  """
  @spec __delegator__() :: module
  def __delegator__ do
    case Application.fetch_env(:delx, :stub) do
      {:ok, true} -> Delx.Delegator.Stub
      _ -> Application.get_env(:delx, :delegator, Delx.Delegator.Common)
    end
  end

  @doc """
  Defines a function that delegates to another module. Has the same API as
  `Kernel.defdelegate/2`.
  """
  defmacro defdel(funs, opts) do
    funs = Macro.escape(funs, unquote: true)

    quote bind_quoted: [funs: funs, opts: opts] do
      target =
        opts[:to] || raise ArgumentError, "expected to: to be given as argument"

      for fun <- List.wrap(funs) do
        {name, args, as, as_args} = Kernel.Utils.defdelegate(fun, opts)

        @doc delegate_to: {target, as, :erlang.length(as_args)}
        def unquote(name)(unquote_splicing(args)) do
          Delx.__delegator__().apply(
            {unquote(__MODULE__), unquote(name)},
            {unquote(target), unquote(as)},
            unquote(args)
          )
        end
      end
    end
  end
end
