defmodule PollsApplicationWeb.Router do
  use PollsApplicationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PollsApplicationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PollsApplicationWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/polls", PollsLive.Index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PollsApplicationWeb do
  #   pipe_through :api
  # end
end
