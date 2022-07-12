defmodule Walcaino.Broadway do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Walcaino.Worker, []},
        transformer: {__MODULE__, :transform, []}
      ],
      processors: [
        default: [concurrency: 10]
      ],
      batchers: [
        s3: [concurrency: 5, batch_size: 50_000, batch_timeout: 2000, partition_by: &partition/1]
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    message
    |> Message.update_data(&process_data/1)
    |> Message.put_batcher(:s3)
  end

  def handle_batch(:s3, messages, _batch_info, _context) do
    # Send batch of messages to S3
    [m | _] = messages
    relation = m.data.relation
    id = :crypto.strong_rand_bytes(16) |> Base.url_encode64 |> binary_part(0, 16)
    filename = "#{relation}.#{id}.parquet"
    |> IO.inspect()
    Explorer.DataFrame.from_rows(
      Enum.map(messages, fn m -> m.data.record end)
    )
    |> Explorer.DataFrame.write_parquet(filename)
    IO.puts "wrote batch #{filename}"
    messages
  end

  defp process_data(data) do
    # Do some calculations, generate a JSON representation, process images.
    {schema, table} = data.relation
    %{data | relation: "#{schema}.#{table}"}
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, successful, failed) do
    # Write ack code here
  end

  defp partition(msg) do
    :erlang.phash2(msg.data.relation)
  end
end