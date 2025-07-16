defmodule EmsbElixir.Health.Status do
  @moduledoc """
  健康状态结构体
  """
  defstruct app: :ok, db: :unknown, minio: :unknown
end

defmodule EmsbElixir.Health.Checker do
  @moduledoc """
  系统健康状态检查服务
  """

  alias EmsbElixir.Repo
  alias EmsbElixir.Health.Status

  @doc """
  执行完整的健康检查
  """
  def check_all do
    %Status{
      app: :ok,
      db: check_db(),
      minio: check_minio()
    }
  end

  defp check_db do
    case Repo.query("SELECT 1") do
      {:ok, _} -> :ok
      _ -> :error
    end
  end

  defp check_minio do
    try do
      # 尝试列出 buckets（轻量级操作）
      case ExAws.S3.list_buckets() |> ExAws.request() do
        {:ok, _} -> :ok
        _ -> :error
      end
    rescue
      _ -> :error
    end
  end
end

