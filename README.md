# Deadline

<!-- MDOC !-->

Deadline is a small library for managing deadlines and for performing deadline
propagation across systems. It uses process dictionary both for performance
and to make the library more ergonomic.

```elixir
# Set a deadline in milliseconds
Deadline.set(1_000)

# Perform some work that takes longer than a second
Deadline.work(fn ->
  Service.call()
end)

# Won't be called because we've exceeded our deadline
Deadline.work(fn ->
  Service.call()
end)
```

<!-- MDOC !-->

## Installation

```elixir
def deps do
  [
    {:deadline, "~> 0.1.0"}
  ]
end
```

