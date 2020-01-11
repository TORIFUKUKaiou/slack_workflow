defmodule SlackWorkflow do
  @moduledoc """
  Documentation for SlackWorkflow.
  """

  def main(argv) do
    argv
    |> parse_argv()
    |> process()
  end

  def create_csvs(channel, oldest, latest) do
    SlackWorkflow.Applications.run(channel, oldest, latest)
    |> Enum.each(fn {name, list_of_keywords} ->
      list_of_lists =
        list_of_keywords
        |> Enum.map(fn keywords ->
          Enum.reduce(keywords, [], fn {_k, v}, acc ->
            acc ++ [v]
          end)
        end)

      header =
        list_of_keywords
        |> List.first()
        |> Keyword.keys()

      [header]
      |> Kernel.++(list_of_lists)
      |> CSV.encode()
      |> Enum.join()
      |> (fn content -> File.write("#{name}.csv", content) end).()
    end)
  end

  def hello, do: :world

  defp parse_argv(argv) do
    parse =
      OptionParser.parse(argv, strict: [channel: :string, oldest: :integer, latest: :integer])

    case parse do
      {[channel: channel, oldest: oldest, latest: latest], _, _} -> {channel, oldest, latest}
      {[channel: channel, latest: latest, oldest: oldest], _, _} -> {channel, oldest, latest}
      {[latest: latest, channel: channel, oldest: oldest], _, _} -> {channel, oldest, latest}
      {[latest: latest, oldest: oldest, channel: channel], _, _} -> {channel, oldest, latest}
      {[oldest: oldest, channel: channel, latest: latest], _, _} -> {channel, oldest, latest}
      {[oldest: oldest, latest: latest, channel: channel], _, _} -> {channel, oldest, latest}
      _ -> :help
    end
  end

  defp process({channel, oldest, latest}), do: create_csvs(channel, oldest, latest)

  defp process(:help) do
    IO.puts("""
    usage: slack_workflow --channel channel --oldest oldest --latest latest
    """)

    System.halt(0)
  end
end
