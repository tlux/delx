# Delx

[![Build Status](https://travis-ci.org/i22-digitalagentur/delx.svg?branch=master)](https://travis-ci.org/i22-digitalagentur/delx)
[![Hex.pm](https://img.shields.io/hexpm/v/delx.svg)](https://hex.pm/packages/delx)

[Defdelegate](https://hexdocs.pm/elixir/Kernel.html#defdelegate/2) on steroids!
An Elixir library to make function delegation testable.

## Prerequisites

* Erlang 20 or greater
* Elixir 1.8 or greater

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `delx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:delx, "~> 2.1"}
  ]
end
```

## Usage

Check out the full docs at [https://hexdocs.pm/delx](https://hexdocs.pm/delx).

Let's say you have the following module.

```elixir
defmodule Greeter.StringGreeter do
  def hello(name) do
    "Hello, #{name}!"
  end
end
```

You can delegate functions calls to another module by using the `Delx` module
and calling the `defdel/2` macro in the module body. It has the same API as
Elixir's own `Kernel.defdelegate/2` macro.

```elixir
defmodule Greeter do
  use Delx, otp_app: :greeter

  defdel hello(name), to: Greeter.StringGreeter
end

Greeter.hello("Tobi")
# => "Hello, Tobi!"
```

## Testing

One great benefit of Delx is that you can test delegation without invoking
the actual implementation of the delegation target, thus eliminating all side
effects.

### Built-In Assertions

Delx brings it's own test assertions.

All you need to do is to activate delegation mocking for your test environment
by putting the following line in your `config/test.exs`:

```elixir
config :greeter, Delx, mock: true
```

Then in your tests, you can import `Delx.TestAssertions` and use the
`assert_delegate/2` and `refute_delegate/2` assertions.

```elixir
defmodule GreeterTest do
  use ExUnit.Case

  import Delx.TestAssertions

  describe "hello/1" do
    test "delegate to Greeter.StringGreeter" do
      assert_delegate {Greeter, :hello, 1}, to: Greeter.StringGreeter
    end
  end
end
```

Note that once you activate mocking all delegated functions do not return
anymore but instead raise the `Delx.MockedDelegationError`. If you really
want to call the original implementation, you have to avoid any calls of
delegated functions.

### With Mox

If you are using [Mox](https://hexdocs.pm/mox) in your application you have
another possibility to test delegated functions.

Register a mock for the `Delx.Delegator` behavior to your
`test/test_helper.exs` (or wherever you define your mocks):

```elixir
Mox.defmock(Delx.Delegator.Mock, for: Delx.Delegator)
```

Then, in your `config/test.exs` you have to set the mock as delegator module
for your app.

```elixir
config :my_app, Delx, delegator: Delx.Delegator.Mock
```

Please make sure not to use the `:mock` option and a `:delegator` option at the
same time as this may lead to unexpected behavior.

Now you are able to `expect` calls to delegated functions:

```elixir
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
```

For more information on how to implement your own delegator, refer to the
docs of the `Delx.Delegator` behavior.

Note that the configuration is only applied at compile time, so you are unable
to mock or replace the delegator module at runtime.
