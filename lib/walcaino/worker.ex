defmodule Walcaino.Worker do
  use GenStage

  def start_link(_) do
    GenStage.start_link(__MODULE__, [])
  end

  def init(_) do
    Cainophile.Adapters.Postgres.subscribe(Cainophile.ExamplePublisher, self())
    {:producer, []}
  end

  def handle_info(%Cainophile.Changes.Transaction{changes: changes}, state) do
    {:noreply, changes, []}
  end

  def handle_demand(demand, state) when demand > 0 do
    {:noreply, [], []}
  end
end
