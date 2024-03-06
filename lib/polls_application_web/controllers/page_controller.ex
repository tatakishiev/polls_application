defmodule PollsApplicationWeb.PageController do
  use PollsApplicationWeb, :controller

  def index(conn, params) do
    if get_session(conn, :current_user) do
      redirect(conn, to: "/polls")
    else
      new_user = params["user_name"]

      if new_user == nil do
        render(conn, :home, layout: false)
      else
        conn
        |> put_session(:current_user, new_user)
        |> redirect(to: "/polls")
      end
    end
  end

  defp handle_new_user(conn, %{"user_name" => user_name} = _params) do
    trimmed_user_name = String.trim(user_name)

    if trimmed_user_name != "" do
      case PollApp.UserSessionManager.add_user_name(trimmed_user_name) do
        :ok ->
          conn
          |> put_session(:user_name, trimmed_user_name)
          |> redirect(to: "/polls")

        {:error, :already_taken} ->
          conn
          |> put_flash(:error, "User name already taken. Please choose another.")
          |> render("index.html")
      end
    else
      conn
      |> put_flash(:error, "User name cannot be empty.")
      |> render("index.html")
    end
  end

  # Render the homepage for new or returning visitors without a session
  defp handle_new_or_returning_visitor(conn, _params), do: render(conn, "index.html")
end
