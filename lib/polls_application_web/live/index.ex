defmodule PollsApplicationWeb.UserLive.Index do
  use PollsApplicationWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{}))

    {:ok, socket}
  end

  def handle_event("submit", %{"name" => params}, socket) do
    IO.inspect(params)

    socket =
      socket
      |> put_flash(:info, "User created")
      #  |> assign(:user, params.name)
      |> push_navigate(to: ~p"/polls")

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
    """
  end
end
