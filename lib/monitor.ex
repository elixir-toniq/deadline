defmodule Deadline.Monitor do
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