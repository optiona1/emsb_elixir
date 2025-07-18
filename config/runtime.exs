import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/emsb_elixir start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :emsb_elixir, EmsbElixirWeb.Endpoint, server: true
end

if config_env() == :prod do
  # minio
  minio_endpoint = System.get_env("MINIO_ENDPOINT", "http://localhost:9000")
  minio_access_key = System.get_env("MINIO_ACCESS_KEY", "minioadmin")
  minio_secret_key = System.get_env("MINIO_SECRET_KEY", "minioadmin")

  config :ex_aws,
    access_key_id: minio_access_key,
    secret_access_key: minio_secret_key,
    s3: [
      scheme: URI.parse(minio_endpoint).scheme,
      host: URI.parse(minio_endpoint).host,
      port: URI.parse(minio_endpoint).port || 9000,
      # MinIO 默认 region
      region: "us-east-1"
    ],
    debug_requests: true

  # 获取数据库配置
  db_host = System.get_env("DB_HOST", "db")
  db_port = System.get_env("DB_PORT", "3306")
  db_user = System.get_env("DB_USER", "root")
  db_pass = System.get_env("DB_PASSWORD", "root")
  db_name = System.get_env("DB_NAME", "emsb_elixir_#{config_env()}")

  database_url =
    System.get_env("DATABASE_URL") ||
      "mysql://#{db_user}:#{db_pass}@#{db_host}:#{db_port}/#{db_name}"

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :emsb_elixir, EmsbElixir.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :emsb_elixir, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :emsb_elixir,
    access_token_secret_key:
      System.get_env("ACCESS_TOKEN_SECRET_KEY") || "dev_secret_please_change_me"

  config :emsb_elixir, EmsbElixirWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :emsb_elixir, EmsbElixirWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :emsb_elixir, EmsbElixirWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :emsb_elixir, EmsbElixir.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
