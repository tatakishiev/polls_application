defmodule PollsApplication.Presence do
  use Phoenix.Presence,
    otp_app: :application_poll,
    pubsub_server: PollsApplication.PubSub
end
