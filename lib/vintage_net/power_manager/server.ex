defmodule VintageNet.PowerManager.Server do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def reset(server) do
    GenServer.cast(server, :reset)
  end

  def power_off(server) do
    GenServer.cast(server, :power_off)
  end

  @impl true
  def init(_opts) do
    state = %{}
    {:ok, state}
  end

  def handle_cast(:reset, state) do
    {:noreply, state}
  end

  def handle_cast(:power_off, state) do
    {:noreply, state}
  end
end
