defmodule DelxTest.TestAssertionsTest do
  use ExUnit.Case, async: true

  import Delx.TestAssertions

  alias ExUnit.AssertionError

  describe "assert_delegate/1" do
    test "success" do
      assert_delegate(
        {SourceModuleB, :my_other_fun, 0},
        to: TargetModule
      )

      assert_delegate(
        {SourceModuleB, :my_other_fun, 1},
        to: TargetModule
      )
    end

    test "success with :as option" do
      assert_delegate(
        {SourceModuleA, :custom_named_fun, 0},
        to: TargetModule,
        as: :my_other_fun
      )

      assert_delegate(
        {SourceModuleA, :custom_named_fun, 1},
        to: TargetModule,
        as: :my_other_fun
      )
    end

    test "wrong delegation failure" do
      assert_raise AssertionError,
                   ~r/Expected SourceModuleB.my_fun\/3 to delegate to SourceModuleA.my_fun\/3, but instead delegates to TargetModule.my_fun\/3./,
                   fn ->
                     assert_delegate(
                       {SourceModuleB, :my_fun, 3},
                       to: SourceModuleA
                     )
                   end
    end

    test "wrong delegation failure with :as option" do
      assert_raise AssertionError,
                   ~r/Expected SourceModuleB.my_fun\/3 to delegate to SourceModuleA.unknown_fun\/3, but instead delegates to TargetModule.my_fun\/3./,
                   fn ->
                     assert_delegate(
                       {SourceModuleB, :my_fun, 3},
                       to: SourceModuleA,
                       as: :unknown_fun
                     )
                   end
    end

    test "no delegation failure" do
      assert_raise AssertionError,
                   ~r/Expected SourceModuleB.undelegated_fun\/1 to delegate to TargetModule.undelegated_fun\/1, but no delegation found./,
                   fn ->
                     assert_delegate(
                       {SourceModuleB, :undelegated_fun, 1},
                       to: TargetModule
                     )
                   end
    end

    test "no delegation failure with :as option" do
      assert_raise AssertionError,
                   ~r/Expected SourceModuleB.undelegated_fun\/1 to delegate to TargetModule.my_other_fun\/1, but no delegation found./,
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

    test "delegation failure" do
      assert_raise ExUnit.AssertionError,
                   ~r/Expected SourceModuleB.my_other_fun\/1 to not delegate to TargetModule.my_other_fun\/1, but delegation found./,
                   fn ->
                     refute_delegate(
                       {SourceModuleB, :my_other_fun, 1},
                       to: TargetModule
                     )
                   end
    end

    test "delegation failure with :as option" do
      assert_raise ExUnit.AssertionError,
                   ~r/Expected SourceModuleA.custom_named_fun\/1 to not delegate to TargetModule.my_other_fun\/1, but delegation found./,
                   fn ->
                     refute_delegate(
                       {SourceModuleA, :custom_named_fun, 1},
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
