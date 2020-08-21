defmodule Deadline do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @key {__MODULE__, :deadline}

  def set(deadline) do
    Process.put(@key, deadline)
  end

  def get() do
    Process.get(@key)
  end

  def work(f) do
    deadline = Process.get(@key)

    cond do
      deadline == nil ->
        f.()

      deadline <= 0 ->
        {:error, :deadline_exceeded}

      true ->
        start  = System.monotonic_time(:millisecond)
        result = f.()
        stop   = System.monotonic_time(:millisecond)

        duration = stop - start
        deadline = deadline - duration
        set(deadline)

        result
    end
  end
end
