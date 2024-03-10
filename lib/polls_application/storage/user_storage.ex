defmodule PollsApplication.UserStorage do
  alias PollsApplication.User
  alias PollsApplication.User.UserVote
  use GenServer

  def init(_init_arg) do
    {:ok, %{}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_user(username) do
    GenServer.call(__MODULE__, {:add_user, username})
  end

  def vote(username, poll_id, option) do
    GenServer.call(__MODULE__, {:vote, username, poll_id, option})
  end

  def handle_call({:add_user, username}, _from, state) do
    if Map.has_key?(state, username) do
      {:reply, {:error, "username #{username} already taken"}, state}
    else
      user = %User{username: username, votes: []}
      Map.put(state, username, user)
      {:reply, :ok, state}
    end
  end

  def handle_call({:vote, username, poll_id, option}, _from, state) do
    if Map.has_key?(state, username) == false do
      {:reply, {:error, "User: #{username} does not exist"}, state}
    else
      votes = state[username].votes
      Enum.filter(votes, fn x -> x.id == poll_id end)
        |> 
    end
  end
end
