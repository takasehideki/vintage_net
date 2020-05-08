defmodule VintageNet.PowerManager do
  @moduledoc """
  This is a behaviour for implementing platform-specific power management.

  From VintageNet's point of view, network devices have the following
  lifecycle:

  ```
  powered-off   --->  powered-on ---> powering-off ---> powered-off
  ```

  It is important to note that power management does not necessarily mean
  controlling the power. The end effect should be similar, though, since
  VintageNet will try to toggle the power off and on if the network interface
  doesn't seem to be working. For example, unloading the kernel module for the
  network device on "power off" and loading it on "power on" may have the
  desired effect of getting a network interface unstuck.

  VintageNet calls functions here based on how it wants to transition a device.
  VintageNet maintains the device's power status internally, so implementations
  can mostly blindly just do what VintageNet tells them too. Powering on and
  off can be asynchronous to these function calls. VintageNet uses the presence
  or absence of a networking interface (like "wlan0") to determine when one is
  available.

  Two timeouts are important to consider:

  1. power_off_time
  2. power_on_hold_time

  The `power_off_time` specifies the time in the `powering-off` state.  When a
  device is in the `powering-off` state, VintageNet won't bother the device
  until that time has expired. That means that if there's a request to use the
  device, it will wait the `powering-off` time before calling
  `finish_power_off` and then it will power the device back on. This allows
  hardware time to gracefully power off and is strongly recommended in the app
  notes for many devices.

  The `power_on_hold_time` specifies how much time a device should be in the
  `powered-on` state before it is ok to power off again. This allows devices
  some time to initialize and recover on their own.

  Here's an example for a cellular device with a reset line connected to it:

  * `power_on` - De-assert the reset line. Return a `power_on_hold_time` of 10
                 minutes
  * `start_powering_off` - Open the UART and send the power down command to the
                 modem. Return a `power_off_time` of 1 minute.
  * `power_off` - Assert the reset line.
  """

  @doc """
  Initialize state for managing the power to the specified interface

  This is called on start and if the power management GenServer restarts. It
  should not assume that the interface is powered down.
  """
  @callback init(ifname :: VintageNet.ifname(), args :: any()) :: state :: any()

  @doc """
  Power on the hardware behind the specified interface

  The function should turn on power rails, deassert reset lines, load kernel
  modules or do whatever else is necessary to make the interface show up in
  Linux.

  Failure handling is not supported by VintageNet yet, so if power up can fail
  and the right handling for that is to try again later, then this function
  should do that.

  It is ok for this function to return immediately. When the network interface
  appears, VintageNet will start trying to use it.

  The return tuple should include the number of seconds VintageNet should wait
  before trying to power down the module again. This value should be
  sufficiently large to avoid getting into loops where VintageNet gives up on a
  network interface before it has initialized. 10 minutes (600 seconds), for
  example, is a reasonable setting.
  """
  @callback power_on(state :: any(), ifname :: VintageNet.ifname()) ::
              {:ok, next_state :: any(), hold_time :: pos_integer()}

  @doc """
  Start powering off the hardware behind the interface

  This function should start a graceful shutdown of the network interface
  hardware.  It may return immediately. The return value specifies how long in
  seconds VintageNet should wait before calling `power_off/2`. The idea is that
  a graceful power off should be allowed some time to complete, but not
  forever.
  """
  @callback start_powering_off(state :: any(), ifname :: VintageNet.ifname()) ::
              {:ok, next_state :: any(), power_off_time :: pos_integer()}

  @doc """
  Power off the hardware

  This function should finish powering off the network interface hardware. Since
  this is called after the graceful power down should have completed, it should
  forcefully turn off the power to the hardware.
  """
  @callback power_off(state :: any(), ifname :: VintageNet.ifname()) ::
              {:ok, next_state :: any()}
end
