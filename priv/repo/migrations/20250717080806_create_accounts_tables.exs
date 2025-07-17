defmodule EmsbElixir.Repo.Migrations.CreateAccountsTables do
  use Ecto.Migration

  def change do
    create table(:role) do
      add :role_name, :string, size: 64, null: false
      timestamps(type: :utc_datetime)
    end

    create table(:user_role) do
      add :user_id, :integer, null: false
      add :role_id, references(:role, on_delete: :delete_all), null: false

      add :created_dt, :utc_datetime,
        null: false,
        default: fragment("CURRENT_TIMESTAMP")

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_role, [:user_id, :role_id])

    create table(:role_permission) do
      add :role_id, references(:role, on_delete: :delete_all), null: false
      add :permission_code, :string, size: 64, null: false

      add :created_dt, :utc_datetime,
        null: false,
        default: fragment("CURRENT_TIMESTAMP")

      timestamps(type: :utc_datetime)
    end

    create unique_index(:role_permission, [:role_id, :permission_code])
  end
end
