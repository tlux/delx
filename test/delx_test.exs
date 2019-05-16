defmodule DelxTest do
  use ExUnit.Case, async: false

  setup do
    on_exit(fn ->
      Application.delete_env(:my_app, Delx)
    end)

    :ok
  end

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
      Application.put_env(:my_app, Delx, delegator: EchoDelegator)

      defmodule DelegatorFromDelegatorConfig do
        use Delx, otp_app: :my_app
      end

      assert DelegatorFromDelegatorConfig.__delegator__() == EchoDelegator
    end

    test "define __delegator__ returning stub delegator when :stub set to true" do
      Application.put_env(:my_app, Delx, stub: true)

      defmodule DelegatorFromStubConfig do
        use Delx, otp_app: :my_app
      end

      assert DelegatorFromStubConfig.__delegator__() == Delx.Delegator.Stub
    end
  end
end
