# Deadline

<!-- MDOC !-->

Deadline is a small library for managing deadlines and for performing deadline
propagation across systems. It uses process dictionary both for performance
and to make the library more ergonomic.

```elixir
# Set a deadline in milliseconds
Deadline.set(1_000)

# Schedule this process to exit if the deadline is exceeded.
Deadline.exit_after()

# Check to see if you've exceeded a deadline...
if Deadline.reached?() do
  :cancel
else
  do_some_work()
end

# Schedule a task and propagate deadlines.
ctx = Deadline.get()
task = Task.async(fn ->
  # Pass the deadline context to the new function.
  Deadline.set(ctx)
  do_some_work()
end)
Task.await(task, Deadline.time_remaining())
```

<!-- MDOC !-->

## Installation

```elixir
def deps do
  [
    {:deadline, "~> 0.7"}
  ]
end
```

## Should I use this?

This library has been used to serve hundreds of thousands of requests. It's a
very small library and thus should be easy to understand if something doesn't
behave well. Otherwise you should feel confident to use it in production.

The only API that might change is the `time_remaining` function. It currently
returns `:infinity` if no deadline context has been set. This is probably
incorrect and we'd prefer to return nil so it can be easily used like so:

```
Task.await(task, Deadline.time_remaining() || 1_000)
```

Otherwise, very little in the public API is likely to change.
