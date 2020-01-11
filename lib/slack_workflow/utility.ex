defmodule SlackWorkflow.Utility do
  def token, do: Application.get_env(:slack_workflow, :token)
end
