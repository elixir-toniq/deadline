defmodule Deadline.Monitor do
  @moduledoc false
  # This process is used to monitor another process and kill that process if
  # the given deadline is reached. Otherwise, if the calling process ends normally,
  # this process will simply shut itself down gracefully.
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    deadline = Keyword.fetch!(opts, :deadline)
    before_exit = get_in(opts, [:before_exit])
    pid = get_in(opts, [:pid])
    ref = Process.monitor(pid)

    Process.send_after(self(), :exit_monitored_process, deadline)

    {:ok, %{ref: ref, pid: pid, before_exit: before_exit}}
  end

  @impl true
  def handle_info(:exit_monitored_process, %{pid: pid, before_exit: before_exit} = state) do
    if before_exit, do: before_exit.()

    Process.exit(pid, :deadline_exceeded)

    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:DOWN, msg_ref, :process, _, _}, %{ref: ref} = state) when msg_ref == ref do
    {:stop, :normal, state}
  end
end
