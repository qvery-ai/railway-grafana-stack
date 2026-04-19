#!/usr/bin/env bash
# Export GitHub rulesets to .github/rulesets/ as YAML.
# Usage: .github/scripts/export-rulesets.sh [owner/repo]
#
# Requires: gh CLI (authenticated), yq (https://github.com/mikefarah/yq)
#
# Strips GitHub-internal fields (id, node_id, _links, timestamps, source*)
# so the output is a clean, re-importable ruleset definition.

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
OUTDIR="$(git rev-parse --show-toplevel)/.github/rulesets"

mkdir -p "$OUTDIR"

echo "Exporting rulesets for $REPO → $OUTDIR/"

gh api "repos/$REPO/rulesets" --jq '.[].id' | while read -r id; do
  gh api "repos/$REPO/rulesets/$id" | \
    yq -P 'del(.id, .node_id, ._links, .created_at, .updated_at, .current_user_can_bypass, .source, .source_type)' -o yaml \
    > "$OUTDIR/$(gh api "repos/$REPO/rulesets/$id" --jq '.name').yaml"

  name=$(gh api "repos/$REPO/rulesets/$id" --jq '.name')
  echo "  ✓ $name → $OUTDIR/$name.yaml"
done

echo "Done. Review changes with: git diff .github/rulesets/"
