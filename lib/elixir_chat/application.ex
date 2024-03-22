defmodule ElixirChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirChatWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:elixir_chat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirChat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirChat.Finch},
      # Start a worker by calling: ElixirChat.Worker.start_link(arg)
      # {ElixirChat.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirChatWeb.Endpoint,
      ElixirChatWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
