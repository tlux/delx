defmodule Delx.ConfigUtilsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Delx.ConfigUtils
  alias Delx.Delegator.Common, as: CommonDelegator
  alias Delx.Delegator.Mock, as: MockDelegator

  describe "get_delegator/1" do
    test "get delegator for mock option" do
      assert ConfigUtils.get_delegator(mock: true) == MockDelegator
    end

    test "get configured delegator" do
      assert ConfigUtils.get_delegator(delegator: FakeDelegator) ==
               FakeDelegator
    end

    test "get default delegator" do
      assert ConfigUtils.get_delegator(mock: false) ==
               CommonDelegator

      assert ConfigUtils.get_delegator([]) == CommonDelegator
    end
  end
end
