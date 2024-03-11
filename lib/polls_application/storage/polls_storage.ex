defmodule PollsApplication.PollsStorage do
  use GenServer
  alias Phoenix.PubSub

  @name :polls_server

  def init(_init_arg) do
    {:ok, %{}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def get_all() do
    GenServer.call(@name, :get_all)
  end

  def add_poll(poll) do
    GenServer.call(@name, {:add_poll, poll})
  end

  def get_by_id(poll_id) do
    GenServer.call(@name, {:get_by_id, poll_id})
  end

  def delete(poll) do
    GenServer.call(@name, {:delete, poll})
  end

  def upvote(poll, new_vote) do
    GenServer.call(@name, {:upvote, {poll, new_vote}})
  end

  def upvote(poll, new_vote, old_vote) do
    GenServer.call(@name, {:upvote, {poll, new_vote, old_vote}})
  end

  def handle_call(:get_all, _from, polls) do
    {:reply, polls, polls}
  end

  def handle_call({:add_poll, poll}, _from, polls) do
    new_state = Map.put(polls, poll.id, poll)
    PubSub.broadcast(PollsApplication.PubSub, "polls", {:created, poll})
    {:reply, new_state, new_state}
  end

  def handle_call({:get_by_id, poll_id}, _from, state) do
    if Map.has_key?(state, poll_id) do
      {:reply, {:ok, state[poll_id]}, state}
    else
      {:reply, {:error, "Poll not found #{poll_id}"}, state}
    end
  end

  def handle_call({:delete, poll}, _from, state) do
    new_state = Map.delete(state, poll.id)
    PubSub.broadcast(PollsApplication.PubSub, "polls", {:deleted, poll})
    {:reply, :ok, new_state}
  end

  def handle_call({:upvote, {poll, new_vote, old_vote}}, _from, state) do
    poll_option =
      poll.options
      |> Enum.with_index()
      |> Enum.find(fn {poll_option, _idx} -> poll_option.value === old_vote end)

    previous_poll_option = Map.update!(Kernel.elem(poll_option, 0), :count, &(&1 - 1))
    options = List.replace_at(poll.options, Kernel.elem(poll_option, 1), previous_poll_option)
    poll = Map.replace(poll, :options, options)
    state = Map.replace(state, poll.id, poll)

    handle_upvote(poll, new_vote, state)
  end

  def handle_call({:upvote, {poll, new_vote}}, _from, state) do
    handle_upvote(poll, new_vote, state)
  end


  defp handle_upvote(poll, new_vote, state) do
    poll_option =
      poll.options
      |> Enum.with_index()
      |> Enum.find(fn {poll_option, _idx} -> poll_option.value === new_vote end)

    upvoted_poll_option = Map.update!(Kernel.elem(poll_option, 0), :count, &(&1 + 1))
    polls = List.replace_at(poll.options, Kernel.elem(poll_option, 1), upvoted_poll_option)
    poll = Map.replace(poll, :options, polls)
    new_state = Map.replace(state, poll.id, poll)
    PubSub.broadcast(PollsApplication.PubSub, "polls", {:updated, poll})
    {:reply, new_state, new_state}
  end
end
