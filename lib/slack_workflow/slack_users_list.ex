defmodule SlackWorkflow.SlackUsersList do
  @base_url "https://slack.com/api/users.list"

  def fetch do
    build_url()
    |> get()
  end

  defp get(url) do
    json = url |> HTTPoison.get!() |> Map.get(:body) |> Jason.decode!()
    next_cursor = json |> Map.get("response_metadata") |> Map.get("next_cursor")

    get(url, next_cursor, Map.get(json, "members"))
  end

  defp get(_url, "", members), do: members

  defp get(url, next_cursor, got_members) do
    got_members ++ get("#{url}&cursor=#{next_cursor}")
  end

  defp build_url do
    "#{@base_url}?token=#{SlackWorkflow.Utility.token()}"
  end
end
