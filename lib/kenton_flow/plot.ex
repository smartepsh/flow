defmodule KentonFlow.Plot do
  def write_config_file(file_name, output_file, time_range, scopes) do
    f = File.open!("#{file_name}.gp", [:write])

    IO.write(
      f,
      "set terminal png font \"Arial,10\" size 700,500\nset output \"#{output_file}.png\"\nset title \"Elixir Flow processing progress over time\"\nset xlabel \"Time (ms)\"set ylabel \"Items processed\"set key top left\nset xrange [0:#{
        time_range
      }]\nplot #{set_plots(scopes)}"
    )

    File.close(f)
  end

  def gen_png(file_name) do
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
end
