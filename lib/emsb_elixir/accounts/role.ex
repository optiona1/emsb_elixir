defmodule EmsbElixir.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "role" do
    field :role_name, :string

    has_many :role_permissions, EmsbElixir.Accounts.RolePermission, on_delete: :delete_all

    has_many :user_roles, EmsbElixir.Accounts.UserRole, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  def changeset(role, attrs \\ %{}) do
    role
    |> cast(attrs, [:role_name])
    |> validate_required([:role_name])
    |> validate_length(:role_name, max: 64)
  end
end
