defmodule Delx.DefdelegateTest do
  use ExUnit.Case, async: true

  alias Delx.MockedDelegationError

  describe "defdelegate/2" do
    test "define delegated function for single function" do
      try do
        SourceModuleA.my_fun(:arg1_stub, :arg2_stub, :arg3_stub)
      rescue
        error in MockedDelegationError ->
          assert error.source == {SourceModuleA, :my_fun}
          assert error.target == {TargetModule, :my_fun}
          assert error.args == [:arg1_stub, :arg2_stub, :arg3_stub]
      end
    end

    test "define delegated function for multiple functions" do
      try do
        SourceModuleB.my_fun(:arg1_stub, :arg2_stub, :arg3_stub)
      rescue
        error in MockedDelegationError ->
          assert error.source == {SourceModuleB, :my_fun}
          assert error.target == {TargetModule, :my_fun}
          assert error.args == [:arg1_stub, :arg2_stub, :arg3_stub]
      end

      try do
        SourceModuleB.my_other_fun(:arg_stub)
      rescue
        error in MockedDelegationError ->
          assert error.source == {SourceModuleB, :my_other_fun}
          assert error.target == {TargetModule, :my_other_fun}
          assert error.args == [:arg_stub]
      end
    end

    test "define delegated function for function with :as option" do
      try do
        SourceModuleA.custom_named_fun(:arg_stub)
      rescue
        error in MockedDelegationError ->
          assert error.source == {SourceModuleA, :custom_named_fun}
          assert error.target == {TargetModule, :my_other_fun}
          assert error.args == [:arg_stub]
      end
    end

    test "delegate docs" do
      assert {_, _, _, "text/markdown", _, _, doc_entries} =
               Code.fetch_docs(SourceModuleA)

      fun_docs =
        for {{:function, fun, arity}, _, _, _, opts} <- doc_entries,
            into: Map.new(),
            do: {{fun, arity}, opts}

      assert fun_docs[{:custom_named_fun, 1}] == %{
               delegate_to: {TargetModule, :my_other_fun, 1}
             }

      assert fun_docs[{:my_fun, 3}] == %{
               delegate_to: {TargetModule, :my_fun, 3}
             }
    end
  end
end
