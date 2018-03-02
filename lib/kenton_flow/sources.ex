defmodule KentonFlow.Sources do
  alias KentonFlow.Server

  def source(delay \\ 50, count \\ 1000, length \\ 8) do
    Stream.resource(
      fn -> 0 end,
      fn num ->
        if num > count do
          {:halt, num}
        else
          string = Enum.take_random(?a..?z, length) |> List.to_string()
          Process.sleep(delay)
          Server.incr(:load_data)
          {[%{num: num, value: string}, %{num: num, value: string}], num + 1}
        end
      end,
      fn _ -> [] end
    )
  end
end
