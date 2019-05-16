defmodule Delx.DefdelTest do
  use ExUnit.Case, async: false

  setup do
    on_exit(fn ->
      Application.delete_env(:my_app, Delx)
    end)

    :ok
  end

  describe "defdel/2" do
    test "define delegator for single function" do
      assert [:arg1_stub, :arg2_stub, :arg3_stub] =
               SourceModuleA.my_fun(:arg1_stub, :arg2_stub, :arg3_stub)
    end

    test "define delegator for multiple functions" do
      assert [:arg1_stub, :arg2_stub, :arg3_stub] =
               SourceModuleB.my_fun(:arg1_stub, :arg2_stub, :arg3_stub)

      assert :arg_stub = SourceModuleB.my_other_fun(:arg_stub)
    end

    test "define delegator for function with :as option" do
      assert :arg_stub = SourceModuleA.custom_named_fun(:arg_stub)
    end

    test "define delegator for using custom delegator" do
      Application.put_env(:my_app, Delx, delegator: EchoDelegator)

      assert SourceModuleA.my_fun(:arg1_stub, :arg2_stub, :arg3_stub) ==
               {:delx,
                {{SourceModuleA, :my_fun}, {TargetModule, :my_fun},
                 [:arg1_stub, :arg2_stub, :arg3_stub]}}
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
