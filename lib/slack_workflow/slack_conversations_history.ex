defmodule SlackWorkflow.SlackConversationsHistory do
  @base_url "https://slack.com/api/conversations.history"

  def fetch(channel, oldest, latest) do
    build_url(channel, oldest, latest)
    |> get()
  end

  defp build_url(channel, oldest, latest) do
    "#{@base_url}?token=#{SlackWorkflow.Utility.token()}&channel=#{channel}&oldest=#{oldest}&latest=#{
      latest
    }"
  end

  defp get(url) do
    json = url |> HTTPoison.get!() |> Map.get(:body) |> Jason.decode!()

    next_cursor =
      if Map.get(json, "has_more"),
        do: Map.get(json, "response_metadata") |> Map.get("next_cursor"),
        else: nil

    get(url, next_cursor, Map.get(json, "messages"))
  end

  defp get(_url, nil, list), do: list

  defp get(url, cursor, list) do
    list ++ get("#{url}&cursor=#{cursor}")
  end
end
