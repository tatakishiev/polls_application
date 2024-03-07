defmodule PollsApplicationWeb.PageController do
  alias PollsApplication.UserStorage
  use PollsApplicationWeb, :controller

  def index(conn, params) do
    if get_session(conn, :current_user) do
      redirect(conn, to: "/polls")
    else
      new_user = params["user_name"]
      if new_user == nil do
        render(conn, :home, layout: false)
      else
        case UserStorage.add_user(new_user) do
          :ok ->
            IO.inspect("here")
            conn
              |> put_session(:current_user, new_user)
              |> redirect(to: ~p"/polls")
          {:error, error_message} ->
            conn
              |> put_flash(:error, error_message)
              |> render(:home, layout: false)
          _ -> IO.inspect("vashe here")
        end
      end
    end
  end
end
