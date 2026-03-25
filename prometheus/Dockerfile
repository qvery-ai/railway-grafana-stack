ARG VERSION=v3.2.1

FROM prom/prometheus:${VERSION}

# Copy configuration and alerting rules
COPY prom.yml /etc/prometheus/prom.yml
COPY alerts.yml /etc/prometheus/alerts.yml

# Substitute env vars in config at startup, then run Prometheus
ENTRYPOINT ["/bin/sh", "-c", "sed \"s|\\${ALERTMANAGER_INTERNAL_URL}|${ALERTMANAGER_INTERNAL_URL}|g\" /etc/prometheus/prom.yml > /tmp/prom.yml && exec prometheus --config.file=/tmp/prom.yml --storage.tsdb.path=/prometheus --storage.tsdb.no-lockfile"]
