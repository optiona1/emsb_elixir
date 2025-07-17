defmodule EmsbElixir.Auth.PermissionTable do
  alias EmsbElixir.Auth.{Permission, RoutePermission}

  @table [
    %RoutePermission{
      method: "GET",
      path_pattern: "/healthz",
      permission: %Permission{code: :user_read}
    },
    %RoutePermission{
      method: "POST",
      path_pattern: "/api/v1/users",
      permission: %Permission{code: :user_create}
    }
    # 继续补充……
  ]

  def table, do: @table
end
