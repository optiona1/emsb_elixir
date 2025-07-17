defmodule EmsbElixirWeb.Auth.JWT do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss, :jti, :nbf])
    |> add_claim("sub", nil, &is_binary/1)
    |> add_claim("server_types", nil, &is_list/1)
  end

  def verify_token(token) do
    verify_and_validate(token)
  end
end
