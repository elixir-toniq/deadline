defmodule Deadline.MonitorSupervisor do
  @moduledoc false
  use DynamicSupervisor

  alias Deadline.Monitor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_child(pid, deadline, before_exit) do
    spec = {Monitor, deadline: deadline, pid: pid, before_exit: before_exit}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
