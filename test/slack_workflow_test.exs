defmodule SlackWorkflowTest do
  use ExUnit.Case
  doctest SlackWorkflow

  test "greets the world" do
    assert SlackWorkflow.hello() == :world
  end
end
