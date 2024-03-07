defmodule PollsApplication.UserStorage do
  use GenServer

  def init(_init_arg) do
    {:ok, %{}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_user(user_name) do
    GenServer.call(__MODULE__, {:add_user, user_name})
  end

  def handle_call({:add_user, user_name}, _from, state) do
    if Map.has_key?(state, user_name) do
      {:reply, {:error, "username #{user_name} already taken"}, state}
    else
      Map.put(state, user_name, user_name)
      {:reply, :ok, state}
    end
  end
end
