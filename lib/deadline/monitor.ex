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
    pid = Keyword.fetch!(opts, :pid)
    ref = Process.monitor(pid)

    Process.send_after(self(), :kill, deadline)

    {:ok, %{ref: ref, pid: pid}}
  end

  @impl true
  def handle_info(:kill, %{pid: pid} = state) do
    Process.exit(pid, :kill)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:DOWN, msg_ref, :process, _, _}, %{ref: ref} = state) when msg_ref == ref do
    {:stop, :normal, state}
  end
end
