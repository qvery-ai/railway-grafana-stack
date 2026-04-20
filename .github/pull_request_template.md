<!-- TLDR: one sentence — what changed and why -->

## Summary
<!-- Key changes as bullet points -->
-

## Why
<!-- Business/technical motivation -->
<!-- Closes QVE-XXX -->

## What
<!-- Config changes, new alerts/dashboards, scrape targets. -->

## Validation
- [ ] `promtool check config prometheus/prom.yml`
- [ ] `promtool check rules prometheus/alerts.yml`
- [ ] `amtool check-config alertmanager/alertmanager.yml`
- [ ] `docker-compose config`

## Checklist
- [ ] No secrets in config (uses env var substitution)
- [ ] Ready for CodeRabbit review
