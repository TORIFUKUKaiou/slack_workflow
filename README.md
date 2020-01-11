# SlackWorkflow

- This creates the csv files.
- CSV file shows the messages of Slack Workflow channel.
- This works on my workspace, but this may not work on your workspace.
  - Because workspaces have much various variations.

# Requirements
- [Elixir](https://elixir-lang.org/) 1.9

# Usage
```
% mix deps.get
```

## Please set two system environment variables.
- SLACK_TOKEN
  - This token must have the below of scopes.
  - channels:history
  - channels:read
  - users:read
- SLACK_TEAM_DOMAIN
```
export SLACK_TOKEN="xoxp-111111111111-666666666666-666666666666-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
export SLACK_TEAM_DOMAIN="torifuku"
```

## iex

```
% iex -S mix
Erlang/OTP 22 [erts-10.5.3] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)
iex> channel = "workflow"
"workflow"
iex> oldest = 0
0
iex> latest = Timex.now |> Timex.local |> Timex.end_of_day  |> DateTime.to_unix
1578754799
iex> SlackWorkflow.create_csvs(channel, oldest, latest)
:ok
```

## escript
```
% iex -S mix
Erlang/OTP 22 [erts-10.5.3] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)
iex> Tzdata.Util.data_dir()
"/Users/torifukukaiou/slack_workflow/_build/dev/lib/tzdata/priv"
```

### Please rewrite on config/config.exs.
```Elixir:config/config.exs
config :tzdata,
  data_dir: "/Users/torifukukaiou/slack_workflow/_build/dev/lib/tzdata/priv",
  autoupdate: :disabled
```

### Build and Go! 
```
% mix escript.build 
Generated escript slack_workflow with MIX_ENV=dev
% ./slack_workflow --channel workflow --oldest 0 --latest 1578754799
```

Enjoy!
