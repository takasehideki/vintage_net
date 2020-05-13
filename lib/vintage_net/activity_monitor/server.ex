defmodule VintageNet.ActivityMonitor.Server do
  use GenServer

  @all_addresses ["interface", :_, "addresses"]

  @spec start_link(any) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    VintageNet.subscribe(@all_addresses)
    addresses = VintageNet.match(@all_addresses)

    state = %{addresses: addresses}
    {:ok, state}
  end

  @impl true
  def handle_info({VintageNet, ["interface", ifname, "addresses"], _old, new, _}, state) do
    {:noreply, state}
  end

  
end
