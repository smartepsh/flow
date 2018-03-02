defmodule KentonFlow.Operations do
  alias KentonFlow.{Sources, Server}

  # souce (delay, count, length)
  # scope (execute, final)
  def flow do
    Sources.source(50, 200)
    |> Flow.from_enumerable(max_demand: 50, stages: 2)
    |> Flow.partition(max_demand: 5)
    |> Flow.group_by(& &1.num)
    |> Flow.partition(max_demand: 5)
    |> Flow.reduce(fn -> [] end, fn {_, value}, acc ->
      Server.incr(:execute)
      [value | acc]
    end)
    |> Flow.partition(stages: 4, max_demand: 8)
    |> Flow.each(&final/1)
    |> Flow.run()
  end

  def final(_item) do
    Process.sleep(50)
    Server.incr(:final)
  end
end
