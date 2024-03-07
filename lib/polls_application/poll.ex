defmodule PollsApplication.Poll do
  defstruct [:id, :name, :user, :options]
end

defmodule PollsApplication.Poll.PollOption do
  defstruct [:value, :count]
end
