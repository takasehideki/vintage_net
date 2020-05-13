defmodule VintageNet.PowerManager.StateMachine2 do
  def init() do
    %{state: :down, shutdown_time: 60, hold_time: 600}
  end

  def reset(data) do
    handle(data.state, :reset, data)
  end

  def shutdown(data) do
    handle(data.state, :shutdown, data)
  end

  def timeout(data) do
    handle(data.state, :timeout, data)
  end

  # idle_hold
  defp handle(:idle_hold, :timeout, data) do
    {%{data | state: :idle}, []}
  end

  defp handle(:idle_hold, :shutdown, data) do
    {%{data | state: :shutting_down}, [:run_start_shutdown, {:start_timer, data.shutdown_time}]}
  end

  # idle
  defp handle(:idle, :reset, data) do
    {%{data | state: :resetting}, [:run_start_shutdown, {:start_timer, data.shutdown_time}]}
  end

  defp handle(:idle, :shutdown, data) do
    {%{data | state: :shutting_down}, [:run_start_shutdown, {:start_timer, data.shutdown_time}]}
  end

  # shutting_down
  defp handle(:shutting_down, :reset, data) do
    {%{data | state: :resetting}, []}
  end

  defp handle(:shutting_down, :timeout, data) do
    {%{data | state: :down}, [:run_shutdown]}
  end

  # resetting
  defp handle(:resetting, :timeout, data) do
    {%{data | state: :idle_hold}, [:run_shutdown, :run_reset, {:start_timer, data.hold_time}]}
  end

  defp handle(:resetting, :shutdown, data) do
    {%{data | state: :shutting_down}, []}
  end

  # down
  defp handle(:down, :reset, data) do
    {%{data | state: :idle_hold}, [:run_reset, {:start_timer, data.shutdown_time}]}
  end

  # catch all
  defp handle(_state, _event, data) do
    {data, []}
  end
end
