defmodule Delx.Delegator.MockTest do
  use ExUnit.Case, async: true

  alias Delx.Delegator.Mock
  alias Delx.MockedDelegationError

  describe "apply/3" do
    test "send and return call args" do
      source = {SourceModuleA, :my_fun}
      target = {TargetModule, :my_other_fun}

      args = [
        :arg1_stub,
        :arg2_stub,
        :arg3_stub
      ]

      try do
        Mock.apply(source, target, args)
      rescue
        error in MockedDelegationError ->
          assert error.source == source
          assert error.target == target
          assert error.args == args
      end
    end
  end
end
