defmodule EmsbElixirWeb.Router do
  use EmsbElixirWeb, :router

  pipeline :auth do
    plug EmsbElixirWeb.Auth.JWTPlug
    plug EmsbElixirWeb.Auth.AuthorizationPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmsbElixirWeb do
    pipe_through [:api, :auth]
    # 受保护的路由
    get "/healthz", HealthController, :check
  end

  scope "/api", EmsbElixirWeb do
    pipe_through :api
  end

  scope "/", EmsbElixirWeb do
    pipe_through :api

    # get "/healthz", HealthController, :check
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:emsb_elixir, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
