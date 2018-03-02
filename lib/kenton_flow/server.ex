defmodule KentonFlow.Server do
  use GenServer

  @time_unit :millisecond

  # Client API

  def start_link(scopes \\ []) do
    GenServer.start_link(__MODULE__, scopes, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def incr(scope, n \\ 1) do
    GenServer.cast(__MODULE__, {:incr, scope, n})
  end

  # Server API

  def init(scopes) do
    files =
      Enum.map(scopes, fn scope ->
        {scope, File.open!("#{scope}.log", [:write])}
      end)

    counts = Enum.map(scopes, fn scope -> {scope, 0} end)

    time = :os.system_time(@time_unit)

    Enum.each(files, fn {_, io} -> write(io, time, 0) end)

    {:ok, {time, files, counts}}
  end

  def handle_cast({:incr, scope, n}, {time, files, counts}) do
    {value, counts} = Keyword.get_and_update!(counts, scope, &{&1 + n, &1 + n})

    write(files[scope], time, value)

    {:noreply, {time, files, counts}}
  end

  defp write(file, time, value) do
    time = :os.system_time(@time_unit) - time
    IO.write(file, "#{time}\t#{value}\n")
  end
end
