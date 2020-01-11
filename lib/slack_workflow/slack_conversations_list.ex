defmodule SlackWorkflow.SlackConversationsList do
  @base_url "https://slack.com/api/conversations.list"

  def fetch do
    build_url()
    |> get()
  end

  defp get(url) do
    json = url |> HTTPoison.get!() |> Map.get(:body) |> Jason.decode!()
    next_cursor = json |> Map.get("response_metadata") |> Map.get("next_cursor")

    get(url, next_cursor, Map.get(json, "channels"))
  end

  defp get(_url, "", channels), do: channels

  defp get(url, next_cursor, got_channels) do
    got_channels ++ get("#{url}&cursor=#{next_cursor}")
  end

  defp build_url do
    "#{@base_url}?token=#{SlackWorkflow.Utility.token()}"
  end
end
