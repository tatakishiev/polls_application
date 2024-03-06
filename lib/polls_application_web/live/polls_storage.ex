defmodule PollsApplicationWeb.PollsStorage do
  use GenServer
  alias Phoenix.PubSub

  @name :polls_server

  @start_value []

  def polls_topic() do
    "polls"
  end

  def users_topic() do
    "users"
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @start_value, name: @name)
  end

  def add_poll(poll) do
    GenServer.call(@name, {:add_poll, poll})
  end

  def current() do
    GenServer.call(@name, :current)
  end

  def handle_call(:current, _from, polls) do
    {:reply, polls, polls}
  end

  def handle_call({:add_poll, poll}, _from, state) do
    new_state = [poll | state]
    PubSub.broadcast(PollsApplication.PubSub, "polls", %{poll: poll})
    {:reply, new_state, new_state}
  end
end
