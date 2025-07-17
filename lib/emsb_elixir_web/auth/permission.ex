defmodule EmsbElixirWeb.Auth.Permission do
  # 你需要实现 get_user_permissions/1，通常查数据库
  def get_user_permissions(_user_id), do: ["perm_code1", "perm_code2"]

  def authorize(conn, permission_code) do
    user_id = conn.assigns[:user_id]
    permitted = get_user_permissions(user_id)

    if permission_code in permitted do
      conn
    else
      conn |> Plug.Conn.send_resp(403, "不允许访问该资源") |> Plug.Conn.halt()
    end
  end
end
