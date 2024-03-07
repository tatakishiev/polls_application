defmodule PollsApplication.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PollsApplication.PollsStorage,
      PollsApplication.UserStorage,
      {DNSCluster, query: Application.get_env(:polls_application, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PollsApplication.PubSub},
      # Start a worker by calling: PollsApplication.Worker.start_link(arg)
      # {PollsApplication.Worker, arg},
      # Start to serve requests, typically the last entry
      PollsApplication.Presence,
      PollsApplicationWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PollsApplication.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PollsApplicationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
