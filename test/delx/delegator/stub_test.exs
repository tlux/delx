defmodule Delx.Delegator.StubTest do
  use ExUnit.Case, async: true

  alias Delx.Delegator.Stub
  alias Delx.StubbedDelegationError

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
        Stub.apply(source, target, args)
      rescue
        error in StubbedDelegationError ->
          assert error.source == source
          assert error.target == target
          assert error.args == args
      end
    end
  end
end
