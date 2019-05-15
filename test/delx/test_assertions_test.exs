defmodule DelxTest.TestAssertionsTest do
  use ExUnit.Case, async: false

  import Delx.TestAssertions

  alias Delx.Delegator.Stub, as: StubDelegator

  setup do
    Application.put_env(:delx, :delegator, StubDelegator)

    on_exit(fn ->
      Application.delete_env(:delx, :delegator)
    end)

    :ok
  end

  describe "assert_delegate/1" do
    test "success" do
      assert_delegate(
        {SourceModuleB, :my_other_fun, 1},
        to: TargetModule
      )
    end

    test "success with :as option" do
      assert_delegate(
        {SourceModuleC, :custom_named_fun, 1},
        to: TargetModule,
        as: :my_other_fun
      )
    end

    test "failure" do
      assert_raise ExUnit.AssertionError,
                   ~r/SourceModuleB.undelegated_fun\/1 does not delegate to TargetModule.undelegated_fun\/1/,
                   fn ->
                     assert_delegate(
                       {SourceModuleB, :undelegated_fun, 1},
                       to: TargetModule
                     )
                   end
    end

    test "failure with :as option" do
      assert_raise ExUnit.AssertionError,
                   ~r/SourceModuleB.undelegated_fun\/1 does not delegate to TargetModule.my_other_fun\/1/,
                   fn ->
                     assert_delegate(
                       {SourceModuleB, :undelegated_fun, 1},
                       to: TargetModule,
                       as: :my_other_fun
                     )
                   end
    end

    test "raise on missing :to option" do
      assert_raise ArgumentError, "expected to: to be given as argument", fn ->
        assert_delegate({SourceModuleB, :undelegated_fun, 1})
      end
    end
  end

  describe "refute_delegate/1" do
    test "success" do
      refute_delegate(
        {SourceModuleB, :undelegated_fun, 1},
        to: TargetModule
      )
    end

    test "success with :as option" do
      refute_delegate(
        {SourceModuleB, :undelegated_fun, 1},
        to: TargetModule,
        as: :my_other_fun
      )
    end

    test "failure" do
      assert_raise ExUnit.AssertionError,
                   ~r/SourceModuleB.my_other_fun\/1 unintentionally delegates to TargetModule.my_other_fun\/1/,
                   fn ->
                     refute_delegate(
                       {SourceModuleB, :my_other_fun, 1},
                       to: TargetModule
                     )
                   end
    end

    test "failure with :as option" do
      assert_raise ExUnit.AssertionError,
                   ~r/SourceModuleC.custom_named_fun\/1 unintentionally delegates to TargetModule.my_other_fun\/1/,
                   fn ->
                     refute_delegate(
                       {SourceModuleC, :custom_named_fun, 1},
                       to: TargetModule,
                       as: :my_other_fun
                     )
                   end
    end

    test "raise on missing :to option" do
      assert_raise ArgumentError, "expected to: to be given as argument", fn ->
        assert_delegate({SourceModuleB, :undelegated_fun, 1})
      end
    end
  end
end
