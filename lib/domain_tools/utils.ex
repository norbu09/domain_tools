defmodule DomainTools.Utils do
  def data_dir do
    case Application.fetch_env(:domain_tools, :data_dir) do
      {:ok, nil} -> Application.app_dir(:domain_tools, "priv")
      {:ok, dir} -> dir
      _          -> Application.app_dir(:domain_tools, "priv")
    end
  end
end
