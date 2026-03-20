# Grafana

Grafana instance with provisioned datasources and alerting.

## Directory Structure

```
grafana/
├── dockerfile
├── datasources/
│   └── datasources.yml          # Prometheus datasource
└── provisioning/
    └── alerting/
        ├── alerts.yml            # Alert rules (PromQL conditions)
        ├── contactpoints.yml     # Slack webhook configuration
        └── policies.yml          # Notification routing policies
```

## Alerting

Alerts are managed as code via Grafana's file-based provisioning. All alert config lives in `provisioning/alerting/` and is baked into the Docker image at build time.

### Current Alerts

**API Alerts** (folder: API Alerts)

| Alert | Condition | Severity | Fires After |
|-------|-----------|----------|-------------|
| API Target Down | `up{job="api"} == 0` | critical | 2m |
| API High Error Rate | 5xx rate > 5% | critical | 5m |
| API High Latency (p95) | p95 > 2s | warning | 5m |

**Worker Alerts** (folder: Worker Alerts)

| Alert | Condition | Severity | Fires After |
|-------|-----------|----------|-------------|
| Agents Worker Down | `up{job="agents-worker"} == 0` | critical | 2m |
| ETL Worker Down | `up{job="etl-worker"} == 0` | critical | 2m |

**Temporal Alerts — Critical** (folder: Temporal Alerts)

| Alert | Condition | Severity | Fires After |
|-------|-----------|----------|-------------|
| Agents Worker Dead (No Pollers) | `temporal_num_pollers == 0` | critical | 2m |
| ETL Worker Dead (No Pollers) | `temporal_num_pollers == 0` | critical | 2m |
| Activity Queue Backlog | p95 schedule-to-start > 5s | critical | 5m |
| Workflow Task Queue Backlog | p95 schedule-to-start > 2s | critical | 5m |

**Temporal Alerts — Warning** (folder: Temporal Alerts)

| Alert | Condition | Severity | Fires After |
|-------|-----------|----------|-------------|
| Worker Saturated | activity slots < 5 | warning | 10m |
| High Workflow Failure Rate | failure rate > 5% | warning | 10m |
| Activity Failure Spike | failures > 0.1/s | warning | 5m |
| Slow Activities | p95 latency > 60s | warning | 5m |
| Temporal gRPC Failure Rate | failure rate > 5% | warning | 5m |
| Sticky Cache Pressure | eviction rate > 1/s | warning | 10m |

### Adding a New Alert

Add a new rule entry to `provisioning/alerting/alerts.yml` under the appropriate group (or create a new group):

```yaml
- uid: my-new-alert          # unique ID, never change after deploy
  title: My New Alert
  condition: A                # refId of the query that must be true
  for: 5m                    # how long condition must hold before firing
  labels:
    severity: warning         # warning | critical
    service: api
  annotations:
    summary: "Description shown in Slack notification"
  data:
    - refId: A
      datasourceUid: grafana_prometheus
      relativeTimeRange:
        from: 300             # lookback window in seconds
        to: 0
      model:
        refId: A
        expr: your_promql_expression_here > threshold
```

Key fields:
- **uid** - Must be unique and stable. Changing it creates a duplicate alert.
- **condition** - The `refId` whose result determines firing (truthy = fires).
- **for** - Pending duration before the alert actually fires. Prevents flapping.
- **relativeTimeRange.from** - Lookback window in seconds (300 = 5 minutes).
- **datasourceUid** - Use `grafana_prometheus` (defined in `datasources/datasources.yml`).

For multi-query alerts (e.g., error rate = errors / total), use multiple `data` entries with different `refId`s and a math expression with `datasourceUid: "__expr__"`.

### Adding a New Contact Point

Edit `provisioning/alerting/contactpoints.yml`. Example for a second Slack channel:

```yaml
- uid: slack-oncall
  type: slack
  settings:
    url: "${ANOTHER_WEBHOOK_ENV_VAR}"
```

Then reference it in `policies.yml` to route specific alerts there.

### Notification Routing

Edit `provisioning/alerting/policies.yml` to control which alerts go where:

```yaml
policies:
  - orgId: 1
    receiver: slack-alerts        # default receiver
    group_by: [alertname, service]
    routes:
      - receiver: slack-oncall    # override for critical
        matchers:
          - severity = critical
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PROMETHEUS_INTERNAL_URL` | Yes | Prometheus URL (e.g., `http://prometheus:9090`) |
| `SLACK_WEBHOOK_ALERTS` | Yes | Slack incoming webhook URL for alert notifications |
| `GF_SECURITY_ADMIN_USER` | No | Admin username (default: `admin`) |
| `GF_SECURITY_ADMIN_PASSWORD` | No | Admin password |

## Deploy

1. Set `SLACK_WEBHOOK_ALERTS` env var on the Grafana service in Railway
2. Push changes to trigger a redeploy, or manually:
   ```bash
   railway up
   ```

For local development:
```bash
export SLACK_WEBHOOK_ALERTS=https://hooks.slack.com/services/...
docker compose up --build grafana
```

## Tips

- Test PromQL queries in Grafana Explore or Prometheus UI before adding them as alerts
- Use `for: 0s` during testing to make alerts fire immediately, then set a proper duration
- Alerts can also be viewed/edited in the Grafana UI at **Alerting > Alert rules** — but file-provisioned rules are read-only in the UI
- To make provisioned alerts editable in the UI, remove them from the YAML and recreate via UI (not recommended for version control)
