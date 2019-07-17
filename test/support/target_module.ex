defmodule TargetModule do
  def my_fun(arg1, arg2, arg3) do
    [arg1, arg2, arg3]
  end

  def my_other_fun do
    :no_arg
  end

  def my_other_fun(arg) do
    arg
  end
end
