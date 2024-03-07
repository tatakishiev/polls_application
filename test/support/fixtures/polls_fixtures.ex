defmodule PollsApplication.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PollsApplication.Polls` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> PollsApplication.Polls.create_poll()

    poll
  end
end
