defmodule PollsApplication.UserStorage do
  use GenServer

  @name :polls_server

  def init(_init_arg) do
    {:ok, %{}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_user(user_name) do
    GenServer.call(@name, {:add_user, user_name})
  end

  def handle_call({:add_user, user_name}, _from, state) do
    Map.put(state, user_name, user_name)
    {:reply, state, state}
  end
end
