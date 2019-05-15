defmodule Delx.Delegator.StubTest do
  use ExUnit.Case, async: true

  alias Delx.Delegator.Stub

  describe "apply/3" do
    test "send and return call args" do
      result =
        {:delx, {SourceModuleA, :my_fun}, {TargetModule, :my_other_fun},
         [:arg1_stub, :arg2_stub, :arg3_stub]}

      assert Stub.apply(
               {SourceModuleA, :my_fun},
               {TargetModule, :my_other_fun},
               [
                 :arg1_stub,
                 :arg2_stub,
                 :arg3_stub
               ]
             ) == result

      assert_received ^result
    end
  end
end
