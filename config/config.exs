use Mix.Config

config :slack_workflow,
  token: System.get_env("SLACK_TOKEN"),
  team_domain: System.get_env("SLACK_TEAM_DOMAIN")

config :tzdata,
  # data_dir: "/etc/elixir_tzdata_data",
  autoupdate: :disabled
