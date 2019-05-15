defmodule Delx.Delegator.CommonTest do
  use ExUnit.Case, async: true

  alias Delx.Delegator.Common

  describe "apply/3" do
    test "send and return call args" do
      assert Common.apply(
               {SourceModuleA, :my_fun},
               {TargetModule, :my_fun},
               [
                 :arg1_stub,
                 :arg2_stub,
                 :arg3_stub
               ]
             ) == [
               :arg1_stub,
               :arg2_stub,
               :arg3_stub
             ]
    end
  end
end
