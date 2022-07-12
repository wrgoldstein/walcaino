defmodule Walcaino.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Cainophile.Adapters.Postgres,
        register: Cainophile.ExamplePublisher, # name this process will be registered globally as, for usage with Cainophile.Adapters.Postgres.subscribe/2
        epgsql: %{ # All epgsql options are supported here
          host: 'localhost',
          username: "postgres",
          database: "caino",
          password: "postgres"
        },
        slot: "example", # :temporary is also supported if you don't want Postgres keeping track of what you've acknowledged
        wal_position: {"0", "0"}, # You can provide a different WAL position if desired, or default to allowing Postgres to send you what it thinks you need
        publications: ["example_publication"]
      },
      {Walcaino.Broadway, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Walcaino.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
