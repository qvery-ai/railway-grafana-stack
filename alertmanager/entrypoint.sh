#!/bin/sh
# Substitute environment variables in the config template
sed "s|\${SLACK_WEBHOOK_ALERTS}|${SLACK_WEBHOOK_ALERTS}|g" \
    /etc/alertmanager/alertmanager.yml.tmpl > /etc/alertmanager/alertmanager.yml

exec /bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml \
    --storage.path=/alertmanager
