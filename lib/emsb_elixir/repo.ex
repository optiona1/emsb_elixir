defmodule EmsbElixir.Repo do
  use Ecto.Repo,
    otp_app: :emsb_elixir,
    adapter: Ecto.Adapters.MyXQL
end
