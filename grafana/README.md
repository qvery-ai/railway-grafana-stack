# Grafana

Grafana instance with provisioned Prometheus datasource. Used for dashboards and metric exploration.

Alerting is handled by **Prometheus + Alertmanager** — see `prometheus/alerts.yml` and `alertmanager/alertmanager.yml`.

## Directory Structure

```
grafana/
├── Dockerfile
├── railway.toml
└── datasources.yml       # Prometheus datasource
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PROMETHEUS_INTERNAL_URL` | Yes | Prometheus URL (e.g., `http://prometheus.railway.internal:9090`) |
| `GF_SECURITY_ADMIN_USER` | No | Admin username (default: `admin`) |
| `GF_SECURITY_ADMIN_PASSWORD` | No | Admin password |

## Adding Dashboards

1. Create/export a dashboard as JSON from the Grafana UI
2. Save it to `grafana/dashboards/`
3. Add a dashboard provisioner to the Dockerfile or a provisioning YAML

## Deploy

```bash
# From repo root
railway link   # select grafana service
railway up
```
