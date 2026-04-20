Create a Pull Request for the current branch in the railway-grafana-stack repo.

Optional context: $ARGUMENTS

## Steps

1. Run `git status` and `git diff main...HEAD` to understand all changes
2. Run `git log main..HEAD --oneline` to see commit history
3. Run validation:
   - `docker-compose config`
   - `promtool check config prometheus/prom.yml` (if prometheus/ changed)
   - `promtool check rules prometheus/alerts.yml` (if alerts changed)
   - `amtool check-config alertmanager/alertmanager.yml` (if alertmanager changed)
4. If validation fails, fix issues first and commit
5. Draft PR using the `.github/pull_request_template.md` structure:
   - TLDR (one sentence)
   - Summary (bullet points of key changes)
   - Why (motivation, link Linear task: "Closes QVE-XXX")
   - What (config changes, new alerts/dashboards)
   - Validation (check applicable items)
6. Push branch and create PR:
   ```
   git push -u origin <branch>
   gh pr create --title "<short title>" --body "<filled template>"
   ```

## Rules
- Title: short imperative sentence (under 70 chars)
- Always link Linear task if one exists for this work
- Never create PR if validation is failing
