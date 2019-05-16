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

  You can delegate functions calls to another module by using the `Delx`
  module and using the `defdel/2` macro. It has the same syntax and options as
  Elixir's own `Kernel.defdelegate/2` macro.

      iex> defmodule Greeter do
      ...>   use Delx, otp_app: :greeter

      ...>   defdel hello(name), to: Greeter.StringGreeter
      ...> end

      iex> DelegatingModule.hello("Tobi")
      "Hello, Tobi!"

  ## Testing

  One great benefit of Delx is that you can test delegation without invoking
  the actual implementation of the delegation target, thus eliminating all side
  effects.

  ### With the Stub Delegator

  Delx brings it's own stub delegator.

  You can activate it for your test environment by putting the following line in
  your `config/test.exs`:

      config :greeter, Delx, stub: true
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

  If you are using [Mox](https://hexdocs.pm/mox) in your application you have
  another possibility to test delegates.

  Add the mock for the `Delx.Delegator` behavior to your `test/test_helper.exs`:

      Mox.defmock(Delx.Delegator.Mock, for: Delx.Delegator)

  Then, in your `config/test.exs` you have to set the mock as delegator module.

      config :delx, :delegator, Delx.Delegator.Mock

  Please make sure not to use the `:stub` option and a `:delegator` option at
  the same time as this may lead to unexpected behavior.

  Now you are able to `expect` calls to delegated functions:

      defmodule GreeterTest do
        use ExUnit.Case

        import Mox

        setup :verify_on_exit!

        describe "hello/1" do
          test "delegate to Greeter.StringGreeter" do
            expect(
              Delx.Delegator.Mock,
              :apply,
              fn {Greeter, :hello},
                 {Greeter.StringGreeter, :hello},
                 ["Tobi"] ->
              :ok
            end)

            Greeter.hello("Tobi")
          end
        end
      end
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      otp_app =
        opts[:otp_app] ||
          raise ArgumentError, "expected otp_app: to be given as argument"

      @doc false
      @spec __delegator__() :: module
      def __delegator__ do
        config = Application.get_env(unquote(otp_app), Delx, [])

        case Keyword.fetch(config, :stub) do
          {:ok, true} -> Delx.Delegator.Stub
          _ -> Keyword.get(config, :delegator, Delx.Delegator.Common)
        end
      end

      import Delx.Defdel
    end
  end
end
