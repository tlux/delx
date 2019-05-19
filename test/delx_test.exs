defmodule DelxTest do
  use ExUnit.Case, async: true

  describe "use/2" do
    test "raise when :otp_app option missing" do
      assert_raise ArgumentError,
                   "expected otp_app: to be given as argument",
                   fn ->
                     defmodule OtpAppMissing do
                       use Delx
                     end
                   end
    end

    test "define __delegator__ returning configured :delegator" do
      defmodule DelegatorFromDelegatorConfig do
        use Delx, otp_app: :delx
      end

      assert DelegatorFromDelegatorConfig.__delegator__() == EchoDelegator
    end

    test "define __delegator__ returning stub delegator when :stub set to true" do
      defmodule DelegatorFromStubConfig do
        use Delx, otp_app: :delx
      end

      assert DelegatorFromStubConfig.__delegator__() == Delx.Delegator.Stub
    end
  end
end
