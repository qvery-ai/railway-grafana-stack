ARG VERSION=11.5.2

FROM grafana/grafana-oss:${VERSION}

# copy provisioning (datasources + alerting)
COPY datasources /etc/grafana/provisioning/datasources
COPY provisioning/alerting /etc/grafana/provisioning/alerting