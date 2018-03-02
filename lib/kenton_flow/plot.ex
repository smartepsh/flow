defmodule KentonFlow.Plot do
  def create(file_name, scopes) do
    time_range = get_time_range()
    write_config_file(file_name, scopes, time_range)
    gen_png(file_name)
  end

  defp write_config_file(file_name, scopes, time_range) do
    f = File.open!("#{file_name}.gp", [:write])

    IO.write(
      f,
      "set terminal png font \"Arial,10\" size 700,500\nset output \"#{file_name}.png\"\nset title \"Elixir Flow processing progress over time\"\nset xlabel \"Time (ms)\"set ylabel \"Items processed\"set key top left\nset xrange [0:#{
        time_range
      }]\nplot #{set_plots(scopes)}"
    )

    File.close(f)
  end

  defp gen_png(file_name) do
    System.cmd("gnuplot", ["#{file_name}.gp"])
  end

  defp set_plot_lines(scope, style) do
    "\"#{scope}.log\"\t with lines ls #{style} title \"#{scope}\", \\ \n"
  end

  defp set_plots(scopes) do
    {_, plots} =
      Enum.reduce(scopes, {1, ""}, fn scope, {style, strings} ->
        {style + 1, strings <> set_plot_lines(scope, style)}
      end)

    plots
  end

  defp get_time_range do
    {line, _} = System.cmd("tail", ["-n 1", "final.log"])
    line |> String.split("\t") |> List.first() |> Kernel.+(500)
  end
end
