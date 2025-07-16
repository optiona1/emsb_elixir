defmodule EmsbElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EmsbElixirWeb.Telemetry,
      EmsbElixir.Repo,
      {DNSCluster, query: Application.get_env(:emsb_elixir, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EmsbElixir.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: EmsbElixir.Finch},
      # Start a worker by calling: EmsbElixir.Worker.start_link(arg)
      # {EmsbElixir.Worker, arg},
      # Start to serve requests, typically the last entry
      EmsbElixirWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmsbElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmsbElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
