defmodule EmsbElixir.Auth.Permission do
  @enforce_keys [:code]
  defstruct [:code, :desc]
end
