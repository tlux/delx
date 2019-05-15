defmodule SourceModuleB do
  import Delx

  defdel([my_fun(arg1, arg2, arg3), my_other_fun(arg)], to: TargetModule)
  def undelegated_fun(arg), do: {:ok, arg}
end
