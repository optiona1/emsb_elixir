defmodule EmsbElixirWeb.Auth.JWTPlug do
  @moduledoc """
  Plug 版 JWT Bearer，功能与 FastAPI 的 JWTBearer 一一对应。
  """
  @behaviour Plug
  import Plug.Conn
  require Logger

  @excluded_paths ["/docs", "/openapi.json", "/redoc", "/swagger"]

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    if skip_auth?(conn) do
      conn
    else
      try do
        conn
        |> check_server_type()
        |> verify_jwt()
        |> validate_permissions()
        |> put_assigns()
      rescue
        e in Plug.Conn.WrapperError ->
          raise e

        e ->
          Logger.error("Authentication system error: #{inspect(e)}")
          send_error_resp(conn, 500, "Internal authentication error")
      end
    end
  end

  # ---------- 白名单 ----------
  defp skip_auth?(conn) do
    Enum.any?(@excluded_paths, &String.starts_with?(conn.request_path, &1))
  end

  # ---------- Server-Type 头 ----------
  defp check_server_type(conn) do
    case get_req_header(conn, "server-type") do
      [type | _] ->
        IO.inspect(type)
        {conn, type}

      [] ->
        send_error_resp(conn, 400, "Missing required Server-Type header")
    end
  end

  # ---------- JWT 验证 ----------
  defp verify_jwt({conn, server_type}) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- EmsbElixir.Token.verify_token(token) do
      {conn, server_type, claims}
    else
      _ -> send_error_resp(conn, 401, "Invalid authentication credentials")
    end
  end

  # ---------- 权限检查 ----------
  defp validate_permissions({conn, server_type, claims}) do
    user_id = claims["sub"]
    server_types = claims["server_types"] || []

    cond do
      is_nil(user_id) ->
        send_error_resp(conn, 401, "Invalid authentication credentials")

      not is_list(server_types) ->
        send_error_resp(conn, 403, "Invalid permission format")

      server_type not in server_types ->
        send_error_resp(conn, 403, "Insufficient service permissions")

      true ->
        {conn, server_type, claims, user_id}
    end
  end

  # ---------- 写入 conn.assigns ----------
  defp put_assigns({conn, server_type, claims, user_id}) do
    # 异步/同步均可
    roles = EmsbElixir.Accounts.get_user_roles(user_id)

    conn
    |> assign(:user_id, user_id)
    |> assign(:roles, roles)
    |> assign(:server_type, server_type)
    |> assign(:token, claims)
  end

  # ---------- 工具 ----------
  defp send_error_resp(conn, status, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{detail: message}))
    |> halt()
  end
end
