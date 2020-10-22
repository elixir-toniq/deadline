defmodule Deadline do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @key {__MODULE__, :ctx}

  @doc """
  Sets the deadline context. If a integer is passed it is assumed to be the
  desired deadline in milliseconds. This function also accepts a full deadline
  context. This is most commonly used when a deadline has already been set and
  the context needs to be propagated to another BEAM process.
  """
  def set(nil), do: nil
  def set(ctx) when is_map(ctx), do: Process.put(@key, ctx)
  def set(deadline) when is_integer(deadline) do
    start    = current_time()
    deadline = System.convert_time_unit(deadline, :millisecond, :native)
    ctx      = %{deadline: start + deadline, start: start}

    Process.put(@key, ctx)
  end

  @doc """
  Returns the deadline context.
  """
  def get do
    Process.get(@key)
  end

  @doc """
  Forces the calling process to exit if the deadline is reached. This will start
  a new process and that process will live as long as the calling process lives
  or until the deadline is reached. The extra processes should not present a
  problem in most cases, but it could present memory pressure in low memory environments.
  """
  def exit_after do
    case Deadline.MonitorSupervisor.start_child(self(), time_remaining()) do
      {:ok, _pid} -> :ok
      {:error, _error} -> :error
    end
  end

  @doc """
  Returns the remaining time before the dealine is reached, in a given unit. Defaults to `:millisecond` units.
  If the deadline has been exceeded than the time remaining will be 0.
  """
  def time_remaining(unit \\ :millisecond) do
    case Process.get(@key) do
      nil ->
        :infinity

      ctx ->
        # Don't allow the value to go negative
        max(0, to_unit(unit, ctx.deadline - current_time()))
    end
  end

  @doc """
  Checks if a deadline has been reached or exceeded.
  """
  def reached? do
    case Process.get(@key) do
      nil ->
        false

      ctx ->
        current_time() > ctx.deadline
    end
  end


  @doc deprecated: """
  work/1 is not considered to be a safe operation. You should instead use the other
  primitives in Deadline, or spawn a `Task` with the specified deadline like so:

  Task.async(fn -> do_some_work() end)
  |> Task.await(Deadline.time_remaining())
  """
  @deprecated "Use exit_after instead."
  def work(f) do
    ctx = Process.get(@key)
    now = current_time()

    cond do
      ctx == nil ->
        f.()

      now > ctx.deadline ->
        {:error, :deadline_exceeded}

      true ->
        timeout  = to_unit(:millisecond, ctx.deadline - now)
        {:ok, t} = :timer.exit_after(timeout, :canceled)
        result = f.()
        :timer.cancel(t)
        result
    end
  end

  defp current_time do
    System.monotonic_time()
  end

  defp to_unit(:native, value), do: value
  defp to_unit(unit, value) do
    System.convert_time_unit(value, :native, unit)
  end
end
