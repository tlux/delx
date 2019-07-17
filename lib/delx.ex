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
  module and calling the `Delx.Defdel.defdel/2` macro in the module body. It has
  the same API as Elixir's own `Kernel.defdelegate/2` macro.

      iex> defmodule Greeter do
      ...>   use Delx, otp_app: :greeter

      ...>   defdel hello(name), to: Greeter.StringGreeter
      ...> end

      iex> Greeter.hello("Tobi")
      "Hello, Tobi!"

  The reason you need to use `Delx` and define the `:otp_app` option is that
  each application can configure their own delegation behavior. So third-party
  libaries that also use Delx remain unaffected of your application-specific
  configuration.

  ## Testing

  One great benefit of Delx is that you can test delegation without invoking
  the actual implementation of the delegation target, thus eliminating all side
  effects.

  ### Built-In Assertions

  Delx brings it's own test assertions.

  All you need to do is to activate delegation mocking for your test
  environment by putting the following line in your `config/test.exs`:

      config :greeter, Delx, mock: true

  Then in your tests, you can import `Delx.TestAssertions` and use the
  `Delx.TestAssertions.assert_delegate/2` and
  `Delx.TestAssertions.refute_delegate/2` assertions.

      defmodule GreeterTest do
        use ExUnit.Case

        import Delx.TestAssertions

        describe "hello/1" do
          test "delegate to Greeter.StringGreeter" do
            assert_delegate {Greeter, :hello, 1}, to: Greeter.StringGreeter
          end
        end
      end

  Note that once you activate mocking all delegated functions do not return
  anymore but instead raise the `Delx.MockedDelegationError`. If you really
  want to call the original implementation, you have to avoid any calls of
  delegated functions.

  ### With Mox

  If you are using [Mox](https://hexdocs.pm/mox) in your application you have
  another possibility to test delegated functions.

  Register a mock for the `Delx.Delegator` behavior to your
  `test/test_helper.exs` (or wherever you define your mocks):

      Mox.defmock(Delx.Delegator.Mock, for: Delx.Delegator)

  Then, in your `config/test.exs` you have to set the mock as delegator module
  for your app.

      config :my_app, Delx, delegator: Delx.Delegator.Mock

  Please make sure not to use the `:mock` option and a `:delegator` option at
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
              end
            )

            Greeter.hello("Tobi")
          end
        end
      end

  For more information on how to implement your own delegator, refer to the
  docs of the `Delx.Delegator` behavior.

  Note that the configuration is only applied at compile time, so you are unable
  to mock or replace the delegator module at runtime.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      otp_app =
        opts[:otp_app] ||
          raise ArgumentError, "expected otp_app: to be given as argument"

      config = Application.get_env(otp_app, Delx, [])

      case Keyword.fetch(config, :mock) do
        {:ok, true} ->
          @delegator Delx.Delegator.Mock

        _ ->
          @delegator Keyword.get(config, :delegator, Delx.Delegator.Common)
      end

      import Kernel, except: [defdelegate: 2]
      import Delx.Defdelegate
    end
  end
end
