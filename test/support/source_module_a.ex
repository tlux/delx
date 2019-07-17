defmodule SourceModuleA do
  use Delx, otp_app: :delx

  defdel(my_fun(arg1, arg2, arg3), to: TargetModule)

  defdel([custom_named_fun(), custom_named_fun(arg)],
    to: TargetModule,
    as: :my_other_fun
  )
end
