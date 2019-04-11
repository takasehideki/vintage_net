defmodule VintageNet.Application do
  @moduledoc false

  use Application

  @spec start(Application.start_type(), any()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, reason :: any()}
  def start(_type, _args) do
    args = Application.get_all_env(:vintage_net)
    socket_path = Path.join(Keyword.get(args, :tmpdir), Keyword.get(args, :to_elixir_socket))

    children = [
      {VintageNet.ToElixir.Server, socket_path},
      {VintageNet.Applier, args},
      {VintageNet.Interface.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: VintageNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end