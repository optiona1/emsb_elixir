defmodule EmsbElixirWeb.Auth.RoutePermissionPlug do
  alias EmsbElixirWeb.Auth.Permission

  def init(opts), do: opts

  def call(conn, opts) do
    permission_code = Keyword.fetch!(opts, :permission)
    Permission.authorize(conn, permission_code)
  end
end
