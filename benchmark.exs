defmodule Defdelegate do
  defdelegate hello_world(arg), to: TargetModule
end

defmodule DelxDefdelegate do
  use Delx, otp_app: :delx

  defdelegate hello_world(arg), to: TargetModule
end

defmodule TargetModule do
  def hello_world(arg), do: arg
end

Benchee.run(%{
  "defdelegate without Delx" => fn -> Defdelegate.hello_world(:my_arg) end,
  "defdelegate with Delx" => fn -> DelxDefdelegate.hello_world(:my_arg) end
})
