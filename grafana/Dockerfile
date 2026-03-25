ARG VERSION=11.5.2

FROM grafana/grafana-oss:${VERSION}

# Copy provisioning (datasources only — alerting is handled by Alertmanager)
COPY datasources.yml /etc/grafana/provisioning/datasources/datasources.yml
