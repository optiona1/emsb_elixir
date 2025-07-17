defmodule EmsbElixirWeb.Auth.AuthorizationPlug do
  @moduledoc """
  根据请求方法+路径在 PermissionTable 中查找所需权限，
  再与当前用户权限比对。
  """
  import Plug.Conn
  alias EmsbElixir.Auth.PermissionTable
  alias EmsbElixir.Auth.RoutePermission

  def init(opts), do: opts

  def call(conn, _opts) do
    method = conn.method |> String.upcase()
    path = conn.request_path

    case find_rule(method, path) do
      # 路由表未命中，放行
      nil ->
        conn

      %RoutePermission{permission: permission} ->
        authorize(conn, permission)
    end
  end

  defp find_rule(method, path) do
    Enum.find(PermissionTable.table(), fn rule ->
      rule.method == method and RoutePermission.matches?(rule, path)
    end)
  end

  defp authorize(conn, %EmsbElixir.Auth.Permission{code: code}) do
    user_id = conn.assigns[:user_id]

    # 业务函数：返回 [:user_read, :user_create, ...]
    perms = EmsbElixir.Accounts.get_user_permissions(user_id)

    if code in perms do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(403, Jason.encode!(%{detail: "不允许访问该资源"}))
      |> halt()
    end
  end
end
