defmodule DelxTest do
  use ExUnit.Case, async: false

  alias Delx.Delegator.Common, as: CommonDelegator
  alias Delx.Delegator.Stub, as: StubDelegator

  setup do
    on_exit(fn ->
      Application.delete_env(:delx, :delegator)
      Application.delete_env(:delx, :stub)
    end)

    :ok
  end

  describe "__delegator__/0" do
    test "" do
      Application.put_env(:delx, :stub, true)

      assert Delx.__delegator__() == StubDelegator
    end

    test "get configured delegator" do
      Application.put_env(:delx, :delegator, UnknownDelegator)

      assert Delx.__delegator__() == UnknownDelegator
    end

    test "get default delegator" do
      assert Delx.__delegator__() == CommonDelegator
    end
  end

  describe "defdel/2" do
    test "delegate single function" do
      assert [:arg1_stub, :arg2_stub, :arg3_stub] =
               SourceModuleA.my_fun(:arg1_stub, :arg2_stub, :arg3_stub)
    end

    test "delegate multiple functions" do
      assert [:arg1_stub, :arg2_stub, :arg3_stub] =
               SourceModuleB.my_fun(:arg1_stub, :arg2_stub, :arg3_stub)

      assert :arg_stub = SourceModuleB.my_other_fun(:arg_stub)
    end

    test "delegate function with :as option" do
      assert :arg_stub = SourceModuleC.custom_named_fun(:arg_stub)
    end

    test "delegate using custom delegator" do
      Application.put_env(:delx, :delegator, StubDelegator)

      assert SourceModuleA.my_fun(:arg1_stub, :arg2_stub, :arg3_stub) ==
               {:delx, {SourceModuleA, :my_fun}, {TargetModule, :my_fun},
                [:arg1_stub, :arg2_stub, :arg3_stub]}
    end

    test "delegate docs" do
      assert {:docs_v1, _, _, "text/markdown", _, _,
              [
                {{:function, :my_fun, 3}, _, _, _,
                 %{delegate_to: {TargetModule, :my_fun, 3}}},
                {{:function, :my_other_fun, 1}, _, _, _,
                 %{delegate_to: {TargetModule, :my_other_fun, 1}}},
                _
              ]} = Code.fetch_docs(SourceModuleB)
    end
  end
end
