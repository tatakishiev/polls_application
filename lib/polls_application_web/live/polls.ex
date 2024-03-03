defmodule PollsApplicationWeb.PollsLive.Index do
  alias PollsApplicationWeb.PollsStorage
  alias Phoenix.PubSub
  use PollsApplicationWeb, :live_view

  def mount(_params, _session, socket) do
    PubSub.subscribe(PollsApplication.PubSub, "polls")
    polls = PollsStorage.current()
    IO.inspect(polls)

    socket =
      socket
      |> assign(:polls, polls)
      |> assign(:form, to_form(%{}))

    {:ok, socket}
  end

  def handle_event("submit", %{"name" => params}, socket) do
    PollsStorage.add_poll(params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="grow text-2xl font-bold">Create New Class</h1>
    <.form class="mb-6" for={@form} phx-submit="submit">
      <div>
        <.input field={@form[:name]} type="text" label="Name" />
      </div>
      <div style="padding-top:20px">
        <button class="bg-black border border-black hover:bg-gray-700 text-white font-hold py-2 px-3 rounded-md">
          Save
        </button>
      </div>
    </.form>

    <div>
      <%= for p <- @polls do %>
        <%= p %>
      <% end %>
    </div>
    """
  end
end
