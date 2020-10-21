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
  Kills the calling process after the deadline has passed.
  """
  def exit_after do
    case Deadline.DynamicSupervisor.start_child(self(), time_remaining()) do
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

  @doc """
  Performs some work. If the deadline has already been exceeded then the function
  will not be called and the code will not be executed. If the deadline is reached,
  the calling process will receive an exit signal with the reason of `:canceled`.
  If you do not want the calling process to exit, you will need to trap exits
  and handle any necessary cleanup.
  """
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
        result   = f.()
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
