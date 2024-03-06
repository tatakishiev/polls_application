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
end
