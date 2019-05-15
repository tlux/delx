defmodule SourceModuleC do
  import Delx

  defdel(custom_named_fun(arg), to: TargetModule, as: :my_other_fun)
end
