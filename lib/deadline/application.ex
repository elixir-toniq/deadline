defmodule Deadline.Application do
  @moduledoc false
  use Application

  def start(_type, _opts) do
    children = [
      Deadline.MonitorSupervisor
    ]

    opts = [strategy: :one_for_one, name: Deadline.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
