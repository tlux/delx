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
  end
end
