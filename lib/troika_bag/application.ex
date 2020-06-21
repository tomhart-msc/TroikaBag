defmodule TroikaBag.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {TroikaBag.EventListener, []},
      {Registry, keys: :unique, name: :bag_process_registry},
      {DynamicSupervisor, strategy: :one_for_one, name: TroikaBag.BagSupervisor}
      # Starts a worker by calling: TroikaBag.Worker.start_link(arg)
      # {TroikaBag.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TroikaBag.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
