defmodule PollsApplicationWeb.PollsLive.Index do
  alias PollsApplication.Poll
  alias PollsApplicationWeb.PollsStorage
  alias Phoenix.PubSub
  use PollsApplicationWeb, :live_view

  def mount(_params, session, socket) do
    PubSub.subscribe(PollsApplication.PubSub, "polls")
    polls = PollsStorage.current()

    current_user = session["current_user"]

    socket =
      socket
      |> stream(:polls, polls)
      |> assign(:poll_form, to_form(%{}, as: :poll))
      |> assign(:current_user, current_user)

    {:ok, socket}
  end

  def handle_event("submit", %{"poll" => poll}, socket) do
    poll = %Poll{id: UUID.uuid1(), name: poll["name"], description: poll["description"]}
    PollsStorage.add_poll(poll)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    socket =
      socket
      |> stream_insert(:polls, msg[:poll], at: 0)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="grow text-2xl font-bold"><%= @current_user %>, Lets create poll</h1>
    <.form class="mb-6" for={@poll_form} phx-submit="submit">
      <div>
        <.input field={@poll_form[:name]} type="text" label="Name" />
        <.input field={@poll_form[:description]} type="text" label="Description" />
      </div>
      <div style="padding-top:20px">
        <button class="bg-black border border-black hover:bg-gray-700 text-white font-hold py-2 px-3 rounded-md">
          Publish Poll
        </button>
      </div>
    </.form>
    <.table id="poll" rows={@streams.polls}>
      <:col :let={{_id, poll}} label="Name"><%= poll.name %></:col>
      <:col :let={{_id, poll}} label="Description"><%= poll.description %></:col>
    </.table>
    """
  end
end
