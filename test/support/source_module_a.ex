defmodule SourceModuleA do
  import Delx

  defdel(my_fun(arg1, arg2, arg3), to: TargetModule)
end
