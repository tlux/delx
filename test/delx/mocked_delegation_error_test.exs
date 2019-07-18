defmodule Delx.MockedDelegationErrorTest do
  use ExUnit.Case, async: true

  alias Delx.MockedDelegationError

  describe "Exception.message/1" do
    test "get message" do
      exception = %MockedDelegationError{
        source: {SourceModuleA, :source_fun},
        target: {TargetModule, :target_fun},
        args: ["arg 1", "arg 2"]
      }

      assert Exception.message(exception) ==
               "Delegation from SourceModuleA.source_fun/2 to " <>
                 "TargetModule.target_fun/2 is mocked"
    end
  end
end
