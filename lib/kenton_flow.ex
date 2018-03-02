defmodule KentonFlow do
  alias KentonFlow.{Plot, Server, Operations}

  @scopes [:load_data, :execute, :final]

  def start(file_name) do
    Server.start_link(@scopes)
    Operations.flow()
    Server.stop()
    Plot.create(file_name, @scopes)
  end

  def test do
    data = [
      {"elixir", 1_000},
      {"erlang", 60_000},
      {"concurrency", 3_200_000},
      {"elixir", 4_000_000},
      {"erlang", 5_000_000},
      {"erlang", 6_000_000},
      {"elixir", 0}
    ]

    window =
      Flow.Window.fixed(1, :hour, fn {_word, time} -> time end)
      |> Flow.Window.allowed_lateness(1, :millisecond)

    data
    |> Flow.from_enumerable()
    |> Flow.partition(window: window, stages: 1, max_demand: 5)
    |> Flow.reduce(fn -> %{} end, fn {word, _}, acc ->
      Process.sleep(100)
      Map.update(acc, word, 1, &(&1 + 1))
    end)
  end
end
