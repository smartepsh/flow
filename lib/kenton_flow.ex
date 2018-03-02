defmodule KentonFlow do
  alias KentonFlow.{Plot, Server, Operations}

  @scopes [:load_data, :execute, :final]

  def start(file_name) do
    Server.start_link(@scopes)
    Operations.flow()
    Server.stop()
    Plot.create(file_name, @scopes)
  end
end
