# Monitoring

RustBB writes logs to standard output, can serve metrics for Prometheus, and logs every crash with its version. All three are set in the [configuration](configuration.md).

## Logs

Log lines go to standard output: with systemd, to the journal (`journalctl -u rustbb`); with Docker, to `docker logs`. `RUSTBB_LOG` sets how much is written, such as `info`, `warn` or `info,tower_http=debug`.

`RUSTBB_LOG_FORMAT=json` writes one JSON object per line instead of readable text, for a log collector such as Loki, Vector or Elasticsearch. Each object has `timestamp`, `level`, `message` and the event's own fields; lines written while answering a request carry the request's method and path in `span`:

```json
{"timestamp":"2026-10-30T09:12:44.031907Z","level":"INFO","message":"new user registered","user_id":7,"username":"alice","role":"user","span":{"method":"POST","path":"/register","name":"request"}}
```

Logs never contain the query string of a request: the Telegram sign-in sends its login data there.

## Metrics

`RUSTBB_METRICS_BIND` turns on a Prometheus metrics endpoint on an address of its own, such as `RUSTBB_METRICS_BIND=127.0.0.1:9090`. Prometheus then reads `http://127.0.0.1:9090/metrics`. Nothing else is served there, and the forum's own address never serves metrics.

The metrics need no password, so keep the address private: `127.0.0.1` when Prometheus runs on the same server, or a firewalled port. [`rustbb check`](command-line.md#checking-the-setup) warns when it is not a loopback address. In Docker, the container must listen on all of its addresses, and the host publishes the port on 127.0.0.1 only:

```sh
docker run -d -p 127.0.0.1:8080:8080 -p 127.0.0.1:9090:9090 \
  -e RUSTBB_METRICS_BIND=0.0.0.0:9090 -v rustbb:/var/lib/rustbb --env-file env ofkindness/rustbb:0.5.0
```

| Metric | Type | Meaning |
| --- | --- | --- |
| `rustbb_http_requests_total` | counter | Requests, by `method`, `route` and `status`. The route is the pattern, such as `/t/{id}`, so all topics count together; requests for pages that do not exist count as `unmatched`. |
| `rustbb_http_request_duration_seconds` | histogram | Time to answer, by `route`, from 1 ms to 2.5 s |
| `rustbb_panics_total` | counter | Crashes while answering a request, since the start (see below) |
| `process_resident_memory_bytes` | gauge | Memory in use (Linux only) |
| `rustbb_start_time_seconds` | gauge | When the server started, in Unix seconds |
| `rustbb_build_info` | gauge | Always 1, with the `version` and `commit` as labels |
| `rustbb_db_connections` | gauge | Open database connections |
| `rustbb_db_size_bytes` | gauge | The database file and its write-ahead log |
| `rustbb_users`, `rustbb_topics`, `rustbb_posts` | gauge | Accounts, topics and posts that are not deleted |
| `rustbb_sessions` | gauge | Sign-ins that have not expired |
| `rustbb_notifications_total` | counter | Tries at sending [bot notifications](telegram.md#notifications), by `outcome`: `sent` or `failed` |
| `rustbb_notifications_waiting` | gauge | Notifications not yet sent, including ones to be tried again |

A scrape configuration for Prometheus:

```yaml
scrape_configs:
  - job_name: rustbb
    static_configs:
      - targets: ["127.0.0.1:9090"]
```

Two alerts worth having: `increase(rustbb_panics_total[1h]) > 0`, and a 95th percentile page time over 50 ms, `histogram_quantile(0.95, sum by (le) (rate(rustbb_http_request_duration_seconds_bucket[5m]))) > 0.05`.

## Crashes

A crash (a panic, in Rust's terms) while answering a request is logged as an error with the RustBB version, the place in the source and the thread, and the visitor gets a "Server error" page. The server keeps running. The `rustbb_panics_total` metric counts them.

```
ERROR panic: ... version="0.3.0 (befd76d058 2026-10-29)" location="src/handlers/topic.rs:120:9" thread="tokio-runtime-worker"
```

Every crash is a bug in RustBB, and that line says where to look.
