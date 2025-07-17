defmodule EmsbElixir.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(skip: [:aud])
    |> add_claim("sub", nil, &(&1 != nil))
  end

  def verify_token(token) do
    secret = Application.fetch_env!(:emsb_elixir, :access_token_secret_key)
    verify_and_validate(token, Joken.Signer.create("HS256", secret))
  end
end
