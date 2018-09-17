defmodule DomainTools.Application do
  @moduledoc """
  The DomainTools Application Service.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(DomainTools, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: DomainTools.Supervisor)
  end
end
