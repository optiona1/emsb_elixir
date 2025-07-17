defmodule EmsbElixir.Accounts.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "role_permission" do
    field :permission_code, :string

    field :created_dt, :utc_datetime, read_after_writes: true

    belongs_to :role, EmsbElixir.Accounts.Role

    timestamps(type: :utc_datetime)
  end

  def changeset(rp, attrs \\ %{}) do
    rp
    |> cast(attrs, [:role_id, :permission_code])
    |> validate_required([:role_id, :permission_code])
    |> validate_length(:permission_code, max: 64)
    |> unique_constraint([:role_id, :permission_code])
  end
end
