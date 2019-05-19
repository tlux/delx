defmodule Defdelegate do
  defdelegate hello_world(arg), to: TargetModule
end

defmodule Defdel do
  use Delx, otp_app: :delx

  defdel(hello_world(arg), to: TargetModule)
end

defmodule TargetModule do
  def hello_world(arg), do: arg
end

Benchee.run(%{
  "defdelegate" => fn -> Defdelegate.hello_world(:my_arg) end,
  "defdel" => fn -> Defdel.hello_world(:my_arg) end
})
