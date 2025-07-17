defmodule EmsbElixir.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_role" do
    field :created_dt, :utc_datetime, read_after_writes: true
    field :user_id, :integer

    belongs_to :role, EmsbElixir.Accounts.Role

    timestamps(type: :utc_datetime)
  end

  def changeset(ur, attrs \\ %{}) do
    ur
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
    |> unique_constraint([:user_id, :role_id])
  end
end
