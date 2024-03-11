defmodule PollsApplication.UserStorage do
  alias Hex.API.User
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
      new_state = Map.put(state, username, user)
      {:reply, :ok, new_state}
    end
  end

  def handle_call({:vote, username, poll_id, option}, _from, state) do
    if Map.has_key?(state, username) === false do
      {:reply, {:eror, "User: #{username} does not exist"}, state}
    else
      user = state[username]
      votes = user.votes
      vote = Enum.find(votes, fn x -> x.poll_id == poll_id end)

      cond do
        Enum.empty?(votes) ->
          new_vote = %UserVote{poll_id: poll_id, vote: option}
          new_votes = [new_vote | votes]
          new_user = Map.replace(user, :votes, new_votes)
          new_state = Map.replace(state, username, new_user)
          {:reply, :ok, new_state}
        vote == nil ->
          new_vote = %UserVote{poll_id: poll_id, vote: option}
          new_votes = [new_vote | votes]
          new_user = Map.replace(user, :votes, new_votes)
          new_state = Map.replace(state, username, new_user)
          {:reply, :ok, new_state}
        vote != option ->
          new_vote = %UserVote{poll_id: poll_id, vote: option}
          new_votes = List.delete(votes, vote)
          new_votes = [new_vote | new_votes]
          new_user = Map.replace(user, :votes, new_votes)
          new_state = Map.replace(state, username, new_user)
          {:reply, {:ok, option, vote.vote}, new_state}
        true -> {:reply, {:error, "User #{username} already voted"}, state}
      end
    end
  end
end
