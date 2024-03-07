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

  def upvote(poll, value) do
    GenServer.call(@name, {:upvote, {poll, value}})
  end

  def handle_call(:get_all, _from, polls) do
    {:reply, polls, polls}
  end

  def handle_call({:add_poll, poll}, _from, polls) do
    new_state = Map.put(polls, poll.id, poll)
    PubSub.broadcast(PollsApplication.PubSub, "polls", {:created, poll})
    {:reply, new_state, new_state}
  end

  def handle_call({:get_by_id, poll_id}, _from, polls) do
    if Map.has_key?(polls, poll_id) do
      {:reply, {:ok, polls[poll_id]}, polls}
    else
      {:reply, {:error, "Poll not found #{poll_id}"}, polls}
    end
  end

  def handle_call({:delete, poll}, _from, polls) do
    new_state = Map.delete(polls, poll.id)
    PubSub.broadcast(PollsApplication.PubSub, "polls", {:deleted, poll})
    {:reply, :ok, new_state}
  end

  def handle_call({:upvote, {poll, value}}, _from, polls) do
    if Map.has_key?(polls, poll.id) do
      poll_option =
        poll.options
        |> Enum.with_index()
        |> Enum.find(fn {poll_option, _idx} -> poll_option.value === value end)

      upvoted_poll_option = Map.update!(Kernel.elem(poll_option, 0), :count, &(&1 + 1))
      list = List.replace_at(poll.options, Kernel.elem(poll_option, 1), upvoted_poll_option)
      new = Map.replace(poll, :options, list)
      new_state = Map.replace(polls, new.id, new)
      PubSub.broadcast(PollsApplication.PubSub, "polls", {:updated, new})
      {:reply, new_state, new_state}
    else
      {:reply, {:error, "Poll not found #{poll.id}"}, polls}
    end
  end
end
