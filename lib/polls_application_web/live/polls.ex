defmodule PollsApplicationWeb.PollsLive.Index do
  alias PollsApplication.Poll
  alias PollsApplicationWeb.PollsStorage
  alias Phoenix.PubSub
  use PollsApplicationWeb, :live_view

  def mount(_params, _session, socket) do
    PubSub.subscribe(PollsApplication.PubSub, "polls")
    polls = PollsStorage.current()

    socket =
      socket
      |> stream(:polls, polls)
      |> assign(:form, to_form(%{}))

    {:ok, socket}
  end

  def handle_event("submit", params, socket) do
    poll = %Poll{id: UUID.uuid1(), name: params["name"], description: params["description"]}
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
    <h1 class="grow text-2xl font-bold">Create New Poll</h1>
    <.form class="mb-6" for={@form} phx-submit="submit">
      <div>
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
      </div>
      <div style="padding-top:20px">
        <button class="bg-black border border-black hover:bg-gray-700 text-white font-hold py-2 px-3 rounded-md">
          Publish Poll
        </button>
      </div>
    </.form>

    <.table id="class" rows={@streams.polls}>
      <:col :let={{_id, class}} label="Name"><%= class.name %></:col>
      <:col :let={{_id, class}} label="Description"><%= class.description %></:col>
    </.table>
    """
  end
end
