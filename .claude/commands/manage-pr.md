Handle CodeRabbit review feedback for the current PR.

Optional PR number: $ARGUMENTS

## Steps

1. **Detect PR**: If no number provided, detect from current branch:
   ```
   gh pr view --json number,url,title
   ```

2. **Fetch CodeRabbit comments**:
   ```
   gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | select(.user.login | contains("coderabbit")) | {path: .path, line: .line, body: .body, id: .id}'
   ```
   Also fetch review comments:
   ```
   gh pr view {number} --comments --json comments --jq '.comments[] | select(.author.login | contains("coderabbit"))'
   ```

3. **Triage each comment**:
   - **APPLY**: Valid finding — fix it
   - **SKIP**: Contradicts project conventions, style preference, or false positive

4. **Apply fixes** for all APPLY items:
   - Make the config changes
   - Validate: `docker-compose config`

5. **Commit and push**:
   ```
   git add -A && git commit -m "fix: address CodeRabbit review feedback" && git push
   ```

6. **Reply to threads on GitHub**:
   - APPLY: reply "Fixed in latest commit."
   - SKIP: reply with brief rationale why it's not applicable

7. **Trigger re-review**:
   ```
   gh pr comment {number} --body "@coderabbitai review"
   ```

## Rules
- Never blindly apply all suggestions — evaluate each against CLAUDE.md conventions
- If a suggestion conflicts with project patterns, SKIP with explanation
- Group related fixes into a single commit
