# CLAUDE.md — Qvery Observability Stack

Infrastructure-as-config repo: Prometheus, Alertmanager, Grafana deployed on Railway.
No application code — only YAML configs, Dockerfiles, and shell scripts.

## Structure

```
railway-grafana-stack/
├── prometheus/
│   ├── prom.yml          # Scrape config (targets, intervals)
│   ├── alerts.yml        # Alert rules (all rules in one file, grouped)
│   ├── Dockerfile
│   └── railway.toml
├── alertmanager/
│   ├── alertmanager.yml  # Routing + Slack notifications
│   ├── entrypoint.sh     # Variable substitution for secrets
│   ├── Dockerfile
│   └── railway.toml
├── grafana/
│   ├── datasources.yml   # Prometheus datasource provisioning
│   ├── Dockerfile
│   └── railway.toml
└── docker-compose.yml    # Local development stack
```

## Development

```bash
# Start local stack
docker-compose up --build

# Access
# Prometheus: http://localhost:9090
# Alertmanager: http://localhost:9093
# Grafana: http://localhost:3000 (admin/yourpassword123)
```

## Conventions

- All alert rules in `prometheus/alerts.yml` (one file, grouped by service)
- Alertmanager routing: group by `alertname`, route by `severity`
- Grafana dashboards provisioned via JSON (add to grafana/ if needed)
- Secrets injected via Railway env vars → `entrypoint.sh` substitution
- Each service has its own `Dockerfile` + `railway.toml` for independent deployment

## Validation

```bash
# Validate Prometheus config and rules (requires promtool)
promtool check config prometheus/prom.yml
promtool check rules prometheus/alerts.yml

# Validate Alertmanager config (requires amtool)
amtool check-config alertmanager/alertmanager.yml

# Validate docker-compose
docker-compose config
```

## When to Modify This Repo

- Platform emits new Prometheus metrics → add scrape target in `prom.yml`
- New alert needed → add rule group in `alerts.yml`
- New Grafana dashboard → add JSON provisioning in `grafana/`
- Alert routing change → modify `alertmanager.yml`
