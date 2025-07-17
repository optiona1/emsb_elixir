defmodule EmsbElixirWeb.HealthController do
  use EmsbElixirWeb, :controller

  alias EmsbElixir.Health.Checker

  @doc """
  健康检查端点
  """
  def check(conn, _params) do
    health_status = Checker.check_all()

    case overall_status(health_status) do
      :ok ->
        conn
        |> put_status(200)
        |> json(render_health(health_status))

      :error ->
        conn
        |> put_status(503)
        |> json(render_health(health_status))
    end
  end

  defp overall_status(health) do
    if health.db == :ok and health.minio == :ok do
      :ok
    else
      :error
    end
  end

  defp render_health(health) do
    %{
      status: overall_status(health) |> status_to_string(),
      services: %{
        app: status_to_string(health.app),
        database: status_to_string(health.db),
        object_storage: status_to_string(health.minio)
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  defp status_to_string(:ok), do: "OK"
  defp status_to_string(:error), do: "ERROR"
end
