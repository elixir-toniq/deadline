defmodule Deadline do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @key {__MODULE__, :ctx}

  @doc """
  Sets a deadline in milliseconds.
  """
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
  Returns the time remaining in a given unit. Defaults to `:native` units.
  """
  def time_remaining(unit \\ :native) do
    case Process.get(@key) do
      nil ->
        :infinity

      ctx ->
        to_unit(unit, ctx.deadline - current_time())
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
  Performs some work. If the deadline has already been exceeded than the function
  will not be called and the code will not be executed.
  """
  def work(f) do
    ctx = Process.get(@key)

    if ctx && current_time() > ctx.deadline do
      {:error, :deadline_exceeded}
    else
      f.()
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
