defmodule VintageNet.PowerManager do
  @moduledoc """
  This is a behaviour for implementing platform-specific power management.

  From VintageNet's point of view, network devices have the following
  lifecycle:

  ```
  powered-off   --->  powered-on ---> powering-off ---> powered-off
  ```

  It is important to note that power management does not necessarily
  mean controlling the power. The end effect should be similar, though,
  since VintageNet will try to toggle the power off and on if the
  network interface doesn't seem to be working. For example, unloading
  the kernel module for the network device on "power off" and loading
  it on "power on" may have the desired effect of getting a network
  interface unstuck.

  VintageNet calls functions here based on how it wants to transition
  a device. VintageNet maintains the device's power status internally,
  so implementations can mostly blindly just do what VintageNet tells
  them too. Powering on and off can be asynchronous to these function
  calls. VintageNet uses the presence or absence of a networking interface
  (like "wlan0") to determine when one is available.

  Two timeouts are important to consider:

  1. power_off_time
  2. power_on_hold_time

  The `power_off_time` specifies the time in the `powering-off` state.
  When a device is in the `powering-off` state, VintageNet won't
  bother the device until that time has expired. That means that if
  there's a request to use the device, it will wait the `powering-off`
  time before calling `finish_power_off` and then it will power the
  device back on. This allows hardware time to gracefully power off
  and is strongly recommended in the app notes for many devices.

  The `power_on_hold_time` specifies how much time a device should be
  in the `powered-on` state before it is ok to power off again. This
  allows devices some time to initialize and recover on their own.

  Here's an example for a cellular device with a reset line connected
  to it:

  * `power_on` - De-assert the reset line. Return a `power_on_hold_time`
    of 10 minutes
  * `start_powering_off` - 

  """

  @doc """
  Reset the hardware providing the specified interface

  This is called when VintageNet thinks
  """
  @callback reset(ifname :: VintageNet.ifname()) :: :ok


  @callback disable(ifname :: VintageNet.ifname()) :: :ok

end
