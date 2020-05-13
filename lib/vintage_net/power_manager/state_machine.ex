defmodule VintageNet.PowerManager.StateMachine do
  use GenStateMachine

  @spec start_link(VintageNet.ifname()) :: GenServer.on_start()
  def start_link(ifname) do
    GenStateMachine.start_link(__MODULE__, ifname, name: via_name(ifname))
  end

  defp via_name(ifname) do
    {:via, Registry, {VintageNet.PowerManager.Registry, ifname}}
  end

  def reset(server) do
    GenServer.cast(server, :reset)
  end

  def power_off(server) do
    GenServer.cast(server, :power_off)
  end

  @impl true
  def init(ifname) do
    initial_data = %{ifname: ifname}

    {:ok, :configured, initial_data, actions}
  end

  def handle_event(:cast, :reset, state, data) do
    {:next_state, next_state, data}
  end
end
