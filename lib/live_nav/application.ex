defmodule LiveNav.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveNavWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveNav.PubSub},
      # Start the Endpoint (http/https)
      LiveNavWeb.Endpoint,
      {DynamicSupervisor, name: MyDynSup, strategy: :one_for_one}
      # Start a worker by calling: LiveNav.Worker.start_link(arg)
      # {LiveNav.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveNav.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveNavWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
