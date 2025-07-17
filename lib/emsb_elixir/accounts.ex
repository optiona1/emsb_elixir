defmodule EmsbElixir.Accounts do
  import Ecto.Query
  alias EmsbElixir.Repo
  alias EmsbElixir.Accounts.{Role, UserRole, RolePermission}

  # 获取用户所有权限 code
  def get_user_permissions(user_id) do
    query =
      from rp in RolePermission,
        join: ur in UserRole,
        on: ur.role_id == rp.role_id,
        where: ur.user_id == ^user_id,
        select: rp.permission_code,
        distinct: true

    Repo.all(query)
  end

  # 获取用户所有角色名
  def get_user_roles(user_id) do
    query =
      from r in Role,
        join: ur in UserRole,
        on: ur.role_id == r.id,
        where: ur.user_id == ^user_id,
        select: r.role_name,
        distinct: true

    Repo.all(query)
  end
end
