defmodule SlackWorkflow.Applications do
  def run(channel, oldest, latest) do
    members = fetch_members()

    channel_id = fetch_channels() |> Map.fetch!(channel)

    SlackWorkflow.SlackConversationsHistory.fetch(channel_id, oldest, latest)
    |> Enum.filter(&Map.get(&1, "blocks"))
    |> Enum.map(&{Map.get(&1, "blocks"), Map.get(&1, "ts"), Map.get(&1, "username")})
    |> Enum.map(fn {blocks, ts, name} -> {Enum.at(blocks, 0), ts, name} end)
    |> Enum.filter(fn {blocks, _, _} -> Map.get(blocks, "text") end)
    |> Enum.map(fn {blocks, ts, name} -> {Map.get(blocks, "text"), ts, name} end)
    |> Enum.filter(fn {text_map, _, _} -> Map.get(text_map, "type") == "mrkdwn" end)
    |> Enum.map(fn {text_map, ts, name} -> {Map.get(text_map, "text"), ts, name} end)
    |> Enum.map(fn {text, ts, name} -> {text, first_key_index(text), ts, name} end)
    |> Enum.filter(fn {_, first_key_index, _, _} -> first_key_index end)
    |> Enum.map(fn {text, first_key_index, ts, name} ->
      {text, first_key_index, second_key_index(text, first_key_index), ts, name}
    end)
    |> Enum.map(fn {text, first_key_index, second_key_index, ts, name} ->
      {parse(text, first_key_index, second_key_index, members), ts, name}
    end)
    |> Enum.map(fn {keywords, ts, name} ->
      {Keyword.put(keywords, :created_at, date(ts)), ts, name}
    end)
    |> Enum.map(fn {keywords, ts, name} ->
      {Keyword.merge(keywords, [{"url" |> String.to_atom(), url(ts, channel_id)}]), name}
    end)
    |> Enum.reduce(%{}, fn {keywords, name}, acc_map ->
      list = acc_map |> Map.get(name, [])
      acc_map |> Map.merge(%{name => [keywords] ++ list})
    end)
  end

  defp fetch_members() do
    SlackWorkflow.SlackUsersList.fetch()
    |> Enum.reduce(%{}, fn user, acc ->
      %{"id" => id, "name" => name} = user
      acc |> Map.merge(%{"<@#{id}>" => name})
    end)
  end

  defp fetch_channels() do
    SlackWorkflow.SlackConversationsList.fetch()
    |> Enum.reduce(%{}, fn channel, acc ->
      %{"id" => id, "name" => name} = channel
      acc |> Map.merge(%{name => id})
    end)
  end

  defp strip_url(s) do
    if String.starts_with?(s, "<https://"), do: s |> String.slice(1..-2), else: s
  end

  defp name(s, members) do
    Map.get(members, s, s)
  end

  defp key(k) do
    k
    |> String.split()
    |> Enum.at(-1)
    |> String.codepoints()
    |> Enum.slice(1..-2)
    |> Enum.join()
    |> String.to_atom()
  end

  defp value(v, members) do
    v
    |> String.split()
    |> Enum.at(-1)
    |> String.replace("&gt;", "")
    |> strip_url()
    |> name(members)
  end

  defp first_key_index(s) do
    s |> String.split("\n") |> Enum.find_index(&(&1 =~ ~r/\*.+\*/))
  end

  defp second_key_index(s, first_key_index) do
    s
    |> String.split("\n")
    |> Enum.slice((first_key_index + 1)..-1)
    |> Enum.find_index(&(&1 =~ ~r/\*.+\*/))
    |> Kernel.+(first_key_index)
    |> Kernel.+(1)
  end

  defp parse(s, first_key_index, second_key_index, members) do
    index = if second_key_index - first_key_index > 1, do: first_key_index, else: second_key_index

    s
    |> String.split("\n")
    |> Enum.slice(index..-1)
    |> Enum.reject(&(&1 == "&gt;"))
    |> Enum.reject(&(&1 == ""))
    |> Enum.chunk_every(2)
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.reduce(Keyword.new(), fn [k, v], keywords ->
      keywords
      |> Keyword.merge([{k |> key(), v |> value(members)}])
    end)
  end

  defp date(s) do
    s
    |> String.split(".")
    |> Enum.at(0)
    |> String.to_integer()
    |> DateTime.from_unix!()
    |> Timex.local()
    |> Timex.format!("{YYYY}/{0M}/{0D} {h24}:{0m}:{0s}")
  end

  defp url(s, channel_id) do
    "https://#{team_domain()}.slack.com/archives/#{channel_id}/p#{s |> String.replace(".", "")}"
  end

  defp team_domain, do: Application.get_env(:slack_workflow, :team_domain)
end
