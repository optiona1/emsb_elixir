defmodule EmsbElixir.Auth.RoutePermission do
  @enforce_keys [:method, :path_pattern, :permission]
  # permission 为 %Permission{}
  defstruct [:method, :path_pattern, :permission]

  @doc """
  判断当前请求是否匹配本规则（支持 :* 通配符）
  """
  def matches?(%__MODULE__{path_pattern: pattern}, request_path) do
    String.split(pattern, "/")
    |> Enum.zip(String.split(request_path, "/"))
    |> Enum.all?(fn
      {"*", _} -> true
      {seg1, seg2} -> seg1 == seg2
    end)
  end
end
