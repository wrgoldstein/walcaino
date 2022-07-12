# Walcaino

Messing around with Broadway and Cainophile.

With this application running, run:

```
{:ok, pid} = Postgrex.start_link(database: "caino")

q = "insert into survey_views (shop_id, question_id) values ('abc123', 9);"
for _ <- 0..51_000, do: Postgrex.query!(pid, q, []); :ok
```

and parquet files will be written to local disk.

The next step would be to write the parquet to S3.

