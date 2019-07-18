defmodule SourceModuleA do
  use Delx, otp_app: :delx

  defdelegate my_fun(arg1, arg2, arg3), to: TargetModule

  defdelegate [custom_named_fun(), custom_named_fun(arg)],
    to: TargetModule,
    as: :my_other_fun
end
