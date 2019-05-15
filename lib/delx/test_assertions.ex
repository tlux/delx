defmodule Delx.TestAssertions do
  @moduledoc """
  A module that contains assertions for `ExUnit` to test function delegation.

  Note that you need to activate stubbing for your test environment in order to
  make the assertions work. In your `config/text.exs` file:

      config :delx, :stub, true
  """

  import Exception, only: [format_mfa: 3]
  import ExUnit.Assertions, only: [assert: 2]

  @doc """
  Asserts whether the function specified by MFA (module-function-arity tuple) is
  delegated to the the given target module. Accepts the same options as the
  `Kernel.defdelegate/2` macro.

  ## Options

  * `:to` - The module to which the function delegates to.
  * `:as` - The name of the function in the target module.

  ## Example

      defmodule GreeterTest do
        use ExUnit.Case

        import Delx.TestAssertions

        describe "hello/1" do
          test "delegate to Greeter.StringGreeter" do
            assert_delegate {Greeter, :hello, 1}, to: Greeter.StringGreeter
          end
        end
      end
  """
  @spec assert_delegate(mfa, Keyword.t()) :: no_return
  def assert_delegate({module, fun, arity}, opts \\ []) do
    target = get_delegation_target(opts)
    as_fun = opts[:as] || fun
    args = stub_args(arity)

    assert(
      apply(module, fun, args) ==
        {:delx, {module, fun}, {target, as_fun}, args},
      "#{format_mfa(module, fun, arity)} " <>
        "does not delegate to #{format_mfa(target, as_fun, arity)}"
    )
  end

  defp stub_args(arity) do
    Enum.map(1..arity, &{:arg_stub, &1})
  end

  def refute_delegate({module, fun, arity}, opts \\ []) do
    target = get_delegation_target(opts)
    as_fun = opts[:as] || fun
    args = stub_args(arity)

    assert(
      apply(module, fun, args) !=
        {:delx, {module, fun}, {target, as_fun}, args},
      "#{format_mfa(module, fun, arity)} " <>
        "unintentionally delegates to #{format_mfa(target, as_fun, arity)}"
    )
  end

  defp get_delegation_target(opts) do
    opts[:to] || raise ArgumentError, "expected to: to be given as argument"
  end
end
