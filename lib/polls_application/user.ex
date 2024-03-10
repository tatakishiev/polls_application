defmodule PollsApplication.User do
  defstruct [:username, :votes]
end

defmodule PollsApplication.User.UserVote do
  defstruct [:poll_id, :vote]
end
