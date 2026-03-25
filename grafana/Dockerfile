ARG VERSION=11.5.2

FROM grafana/grafana-oss:${VERSION}

# Copy provisioning
COPY datasources.yml /etc/grafana/provisioning/datasources/datasources.yml
COPY alerting.yml /etc/grafana/provisioning/alerting/alerting.yml
COPY contactpoints.yml /etc/grafana/provisioning/alerting/contactpoints.yml
COPY policies.yml /etc/grafana/provisioning/alerting/policies.yml
