FROM prom/alertmanager:v0.28.1

COPY alertmanager.yml /etc/alertmanager/alertmanager.yml.tmpl
COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod +x /entrypoint.sh
USER nobody

ENTRYPOINT ["/entrypoint.sh"]
