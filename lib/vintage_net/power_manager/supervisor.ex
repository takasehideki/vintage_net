defmodule VintageNet.PowerManager.Supervisor do
  use Supervisor

  @moduledoc false

  @spec start(Application.start_type(), any()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, reason :: any()}
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    power_managers = Application.get_env(:vintage_net, :power_managers)

    children = [
      VintageNet.InterfacesSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
