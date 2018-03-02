defmodule KentonFlow.Operations do
  alias KentonFlow.{Sources, Server}

  # souce (delay, count, length)
  # scope (execute, final)
  def flow do
    # |> Flow.group_by(& &1.num)
    # |> Flow.partition(max_demand: 5)
    Sources.source(10, 200)
    |> Flow.from_enumerable(max_demand: 50, stages: 2)
    |> Flow.partition(
      window: Flow.Window.global() |> Flow.Window.trigger_every(50),
      stages: 2,
      max_demand: 5
    )
    |> Flow.reduce(fn -> [] end, fn value, acc ->
      Server.incr(:execute)
      [value | acc]
    end)
    |> Flow.partition(max_demand: 5)
    |> Flow.map(&final/1)
    |> Flow.run()
  end

  def final(_item) do
    Process.sleep(10)
    Server.incr(:final)
  end
end
