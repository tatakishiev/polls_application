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

  def init(init_arg) do
    {:ok, []}
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
    IO.inspect(polls)
    {:reply, polls, polls}
  end

  def handle_call({:add_poll, poll}, _from, state) do
    new_state = Enum.concat(state, [poll])
    PubSub.broadcast(PollsApplication.PubSub, "polls", {:polls, new_state})
    {:reply, new_state, new_state}
  end
end
