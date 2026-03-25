# Monitoring Stack on Railway

Prometheus + Alertmanager + Grafana deployed on Railway. Metrics collection, alerting with full label preservation, and dashboards.

## Architecture

```
┌──────────────┐     scrape      ┌───────────────────┐
│  API /       │  ◄────────────  │                   │
│  Workers     │    metrics      │    Prometheus      │
└──────────────┘                 │  (rules + scrape)  │
                                 └────────┬──────────┘
                                          │ alerts
                                          ▼
                                 ┌───────────────────┐      Slack
                                 │   Alertmanager     │ ──────────►
                                 │  (routing + notify)│
                                 └───────────────────┘

                                 ┌───────────────────┐
                                 │     Grafana        │  ◄── dashboards
                                 │   (visualization)  │
                                 └───────────────────┘
```

- **Prometheus** — scrapes metrics from services, evaluates alert rules
- **Alertmanager** — receives firing alerts from Prometheus, groups/deduplicates, sends to Slack with full `job` and `instance` labels
- **Grafana** — dashboards and metric exploration (alerting is handled by Alertmanager)

## Project Structure

```
├── prometheus/
│   ├── Dockerfile
│   ├── railway.toml
│   ├── prom.yml              # Scrape config + Alertmanager target
│   └── alerts.yml            # Alert rules (PromQL)
│
├── alertmanager/
│   ├── Dockerfile
│   ├── railway.toml
│   ├── alertmanager.yml      # Slack notification config + routing
│   └── entrypoint.sh         # Env var substitution at runtime
│
├── grafana/
│   ├── Dockerfile
│   ├── railway.toml
│   └── datasources.yml   # Prometheus datasource
│
└── docker-compose.yml         # Local development
```

## Deployment (Railway)

Each service is deployed from its own directory. From the repo root:

```bash
# One-time: link and deploy each service
railway link   # select prometheus service
railway up

railway link   # select alertmanager service
railway up

railway link   # select grafana service
railway up
```

Set **Root Directory** for each service in Railway dashboard:

| Service | Root Directory |
|---------|---------------|
| prometheus | `prometheus` |
| alertmanager | `alertmanager` |
| grafana | `grafana` |

## Local Development

```bash
docker compose up --build
```

Services available at:
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Grafana: http://localhost:3000 (admin / yourpassword123)

## Configuration

### Adding Scrape Targets

Edit `prometheus/prom.yml` and add a new job:

```yaml
- job_name: 'my-service'
  dns_sd_configs:
    - names:
        - 'my-service.railway.internal'
      type: 'AAAA'
      port: 9090
  metrics_path: '/metrics'
```

### Adding Alert Rules

Edit `prometheus/alerts.yml`. All Prometheus labels (`job`, `instance`, etc.) are preserved in notifications.

```yaml
- alert: MyNewAlert
  expr: some_metric{job="my-service"} > threshold
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Description shown in Slack"
    description: "What to do when this fires."
```

For ratio-based alerts (e.g., error rate):

```yaml
- alert: HighErrorRate
  expr: >
    sum by (job, instance) (rate(errors_total[5m]))
    / sum by (job, instance) (rate(requests_total[5m]))
    > 0.05
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Error rate above 5%"
```

### Changing Slack Notification Format

Edit `alertmanager/alertmanager.yml`. The template has access to all Prometheus labels:

```yaml
text: |
  {{ range .Alerts }}
  *{{ .Labels.alertname }}*
  Job: `{{ .Labels.job }}` | Instance: `{{ .Labels.instance }}`
  {{ .Annotations.summary }}
  {{ end }}
```

### Adding Grafana Dashboards

Export a dashboard as JSON from Grafana UI, save it to `grafana/dashboards/`, and add a dashboard provisioner in the Grafana Dockerfile.

## Environment Variables

### Prometheus

| Variable | Required | Description |
|----------|----------|-------------|
| `ALERTMANAGER_INTERNAL_URL` | Yes | e.g., `alertmanager.railway.internal:9093` |

### Alertmanager

| Variable | Required | Description |
|----------|----------|-------------|
| `SLACK_WEBHOOK_ALERTS` | Yes | Slack incoming webhook URL |

### Grafana

| Variable | Required | Description |
|----------|----------|-------------|
| `PROMETHEUS_INTERNAL_URL` | Yes | e.g., `http://prometheus.railway.internal:9090` |
| `GF_SECURITY_ADMIN_USER` | No | Admin username (default: `admin`) |
| `GF_SECURITY_ADMIN_PASSWORD` | No | Admin password |

## Current Alert Rules

### Critical

| Alert | Condition | Fires After |
|-------|-----------|-------------|
| APITargetDown | `up{job="api"} == 0` | 2m |
| AgentsWorkerDown | `up{job="agents-worker"} == 0` | 2m |
| ETLWorkerDown | `up{job="etl-worker"} == 0` | 2m |
| AgentsWorkerDead | No active pollers | 2m |
| ETLWorkerDead | No active pollers | 2m |
| ActivityQueueBacklog | p95 schedule-to-start > 5s | 5m |
| WorkflowTaskQueueBacklog | p95 schedule-to-start > 2s | 5m |

### Warning

| Alert | Condition | Fires After |
|-------|-----------|-------------|
| APIHighErrorRate | 5xx rate > 5% | 5m |
| APIHighLatency | p95 > 2s | 5m |
| WorkerSaturated | Activity slots < 5 | 10m |
| HighWorkflowFailureRate | Failure rate > 5% | 10m |
| WorkflowTaskExecutionFailures | Any execution failures | 5m |
| ActivityFailureSpike | Failures > 0.1/s | 5m |
| SlowActivities | p95 latency > 60s | 5m |
| TemporalGRPCFailureRateHigh | gRPC failure rate > 5% | 5m |
| TemporalLongPollFailureRateHigh | Long-poll failure rate > 5% | 5m |
| StickyCachePressure | Eviction rate > 1/s | 10m |
| StickyCacheLowHitRatio | Hit ratio < 50% | 10m |
| WorkflowWorkerSaturated | Workflow task slots < 5 | 10m |
