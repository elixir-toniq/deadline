defmodule DeadlineTest do
  use ExUnit.Case
  doctest Deadline

  test "allows users to set deadlines" do
    us = self()
    spawn(fn ->
      Deadline.set(800)

      Deadline.work(fn ->
        send(us, :job1)
        :timer.sleep(500)
      end)

      Deadline.work(fn ->
        send(us, :job2)
        :timer.sleep(500)
      end)

      Deadline.work(fn ->
        send(us, :job3)
      end)

      send(us, :cleanup)
    end)

    assert_receive :job1, 1_000
    assert_receive :job2, 1_000
    assert_receive :cleanup, 1_000
    refute_receive :job3, 1_000
  end

  test "returns the result of the function" do
    Deadline.set(100)

    result = Deadline.work(fn ->
      :ok
    end)

    assert result == :ok
  end

  test "executes functions even if the deadline isn't set" do
    assert Deadline.work(fn -> :ok end) == :ok
  end
end
