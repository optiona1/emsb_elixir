defmodule EmsbElixir.Release do
  @moduledoc false
  @app :emsb_elixir

  def migrate do
    Application.ensure_all_started(@app)

    path = Application.app_dir(@app, "priv/repo/migrations")
    Ecto.Migrator.with_repo(EmsbElixir.Repo, fn repo ->
      Ecto.Migrator.run(repo, path, :up, all: true)
    end)
  end
end

