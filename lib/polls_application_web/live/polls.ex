defmodule PollsApplicationWeb.PollsLive.Index do
  alias PollsApplication.UserStorage
  alias PollsApplication.Poll.PollOption
  alias PollsApplication.Poll
  alias PollsApplication.PollsStorage
  alias Phoenix.PubSub
  use PollsApplicationWeb, :live_view

  def mount(_params, session, socket) do
    PubSub.subscribe(PollsApplication.PubSub, "polls")
    polls = Map.values(PollsStorage.get_all())

    current_user = session["current_user"]

    socket =
      socket
      |> stream(:polls, polls)
      |> assign(:poll_form, to_form(%{}, as: :poll))
      |> assign(:current_user, current_user)

    {:ok, socket}
  end

  def handle_event("submit", %{"poll" => poll}, socket) do
    user = socket.assigns.current_user

    options =
      String.split(poll["options"], ",")
      |> Enum.map(fn x -> %PollOption{value: x, count: 0} end)

    poll = %Poll{id: UUID.uuid1(), name: poll["name"], options: options, user: user}
    PollsStorage.add_poll(poll)
    {:noreply, socket}
  end

  def handle_event("delete", %{"poll-id" => poll_id}, socket) do
    current_user = socket.assigns.current_user

    case PollsStorage.get_by_id(poll_id) do
      {:ok, poll} ->
        if poll.user != current_user do
          socket = socket |> assign(error: "No no no...You are not poll owner")
          {:noreply, socket}
        else
          PollsStorage.delete(poll)
          {:noreply, socket}
        end
    end
  end

  def handle_event("upvote", %{"poll-id" => poll_id, "option" => value}, socket) do
    current_user = socket.assigns.current_user

    case UserStorage.vote(current_user, poll_id, value) do
      :ok ->
        case PollsStorage.get_by_id(poll_id) do
          {:ok, poll} ->
            PollsStorage.upvote(poll, value)
            {:noreply, socket}

          {:error, message} ->
            socket |> put_flash(:error, message)
            {:noreply, socket}
        end

      {:ok, new_vote, old_vote} ->
        case PollsStorage.get_by_id(poll_id) do
          {:ok, poll} ->
            PollsStorage.upvote(poll, new_vote, old_vote)
            {:noreply, socket}

          {:error, message} ->
            socket |> put_flash(:error, message)
            {:noreply, socket}
        end

      {:error, message} ->
        socket = socket |> put_flash(:error, message)
        {:noreply, socket}
    end
  end

  def handle_info(event, socket) do
    case event do
      {:created, _} ->
        {:noreply, stream(socket, :polls, Map.values(PollsStorage.get_all()))}

      {:deleted, _} ->
        {:noreply, stream(socket, :polls, Map.values(PollsStorage.get_all()))}

      {:updated, _} ->
        {:noreply, stream(socket, :polls, Map.values(PollsStorage.get_all()))}
    end
  end

  def render(assigns) do
    ~H"""
    <h1 class="grow text-2xl font-bold"><%= @current_user %>, Lets create poll</h1>
    <.form class="mb-6" for={@poll_form} phx-submit="submit">
      <div>
        <.input field={@poll_form[:name]} type="text" label="Name" />
        <.input field={@poll_form[:options]} type="text" label="Options(Comma separated)" />
      </div>
      <div style="padding-top:20px">
        <button class="bg-black border border-black hover:bg-gray-700 text-white font-hold py-2 px-3 rounded-md">
          Publish Poll
        </button>
      </div>
    </.form>

    <div :for={{id, poll} <- @streams.polls} id={id}>
      <p class="font-bold text-lg mb-2">Poll name: <%= poll.name %></p>
      <div class="flex items-center gap-2 mb-2">
        <%= if poll.user == @current_user do %>
          <button
            phx-click="delete"
            phx-value-poll-id={poll.id}
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Delete Poll
          </button>
        <% end %>
      </div>
      <div class="flex items-center gap-2 mb-2">
        <%= for option <- poll.options do %>
          <div class="flex items-center gap-2 mb-2">
            <button
              phx-click="upvote"
              phx-value-poll-id={poll.id}
              phx-value-option={option.value}
              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            >
              <%= option.value %>
            </button>
            <span class="text-sm font-medium"><%= option.count %> votes</span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
