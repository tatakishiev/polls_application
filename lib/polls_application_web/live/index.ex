defmodule PollsApplicationWeb.UserLive.Index do
  alias PollsApplication.Poll
  alias Phoenix.PubSub
  use PollsApplicationWeb, :live_view

  def mount(_params, session, socket) do
    user_id = UUID.uuid1()
    PollsApplication.Presence.track(self(), "presense", socket.id, %{user_id: user_id})
    initial_present = PollsApplication.Presence.list("presense")
    IO.inspect(initial_present)

    socket =
      socket
      |> assign(:current_user, session["current_user"])
      |> assign(:form, to_form(%{}))

    {:ok, socket}
  end

  def handle_event("submit", %{"name" => params}, socket) do
    socket =
      socket
      |> assign(:current_user, params)
      |> put_flash(:info, "Hello #{params}")

    #      |> push_navigate(to: ~p"/polls")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl font-bold">Hello, enter your username</h1>
    <.form class="mb-6" for={@form} phx-submit="submit">
      <div>
        <.input field={@form[:name]} type="text" />
      </div>
      <div style="padding-top:20px">
        <button class="bg-black border border-black hover:bg-gray-700 text-white font-hold py-2 px-3 rounded-md">
          Save
        </button>
      </div>
    </.form>

    <div>@current_user</div>
    """
  end
end
