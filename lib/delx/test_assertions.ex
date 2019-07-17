defmodule Delx.TestAssertions do
  @moduledoc """
  A module that contains assertions for `ExUnit` to test function delegation.

  Note that you need to activate stubbing for your test environment in order to
  make the assertions work. In your `config/test.exs` file:

      config :my_app, Delx, stub: true
  """

  import Exception, only: [format_mfa: 3]
  import ExUnit.Assertions

  alias Delx.StubbedDelegationError

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
  @spec assert_delegate(mfa, Keyword.t()) :: :ok | no_return
  def assert_delegate({mod, fun, arity}, opts \\ []) do
    target_mod = get_target_mod(opts)
    target_fun = opts[:as] || fun
    args = stub_args(arity)

    try do
      apply(mod, fun, args)

      flunk(
        "Expected #{format_mfa(mod, fun, arity)} to delegate to " <>
          "#{format_mfa(target_mod, target_fun, arity)}, but no " <>
          "delegation found."
      )
    rescue
      error in StubbedDelegationError ->
        case error do
          %{
            source: {^mod, ^fun},
            target: {^target_mod, ^target_fun},
            args: ^args
          } ->
            :ok

          %{
            source: {^mod, ^fun},
            target: {actual_target_mod, actual_target_fun},
            args: ^args
          } ->
            flunk(
              "Expected #{format_mfa(mod, fun, arity)} to delegate to " <>
                "#{format_mfa(target_mod, target_fun, arity)}, but instead " <>
                "delegates to " <>
                "#{format_mfa(actual_target_mod, actual_target_fun, arity)}."
            )
        end
    end
  end

  @doc """
  Refutes whether the function specified by MFA (module-function-arity tuple) is
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
            refute_delegate {Greeter, :hello, 1}, to: Greeter.StringGreeter
          end
        end
      end
  """
  @spec refute_delegate(mfa, Keyword.t()) :: :ok | no_return
  def refute_delegate({mod, fun, arity}, opts \\ []) do
    target_mod = get_target_mod(opts)
    target_fun = opts[:as] || fun
    args = stub_args(arity)

    try do
      apply(mod, fun, args)
      :ok
    rescue
      error in StubbedDelegationError ->
        case error do
          %{
            source: {^mod, ^fun},
            target: {^target_mod, ^target_fun},
            args: ^args
          } ->
            flunk(
              "Expected #{format_mfa(mod, fun, arity)} to not delegate to " <>
                "#{format_mfa(target_mod, target_fun, arity)}, but " <>
                "delegation found."
            )

          _ ->
            :ok
        end
    end
  end

  defp stub_args(0), do: []

  defp stub_args(arity) do
    Enum.map(1..arity, &{:arg_stub, &1})
  end

  defp get_target_mod(opts) do
    opts[:to] || raise ArgumentError, "expected to: to be given as argument"
  end
end
