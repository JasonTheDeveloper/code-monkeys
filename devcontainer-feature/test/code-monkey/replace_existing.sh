#!/bin/bash
# Test: replace_existing (agent=true, skills=true, replaceExisting=true)
set -e

source dev-container-features-test-lib

# Verify option files reflect replace_existing scenario
check "replace-existing is true" bash -c '[ "$(cat /usr/local/share/code-monkey/replace-existing)" = "true" ]'
check "option-agent is true" bash -c '[ "$(cat /usr/local/share/code-monkey/option-agent)" = "true" ]'
check "option-skills is true" bash -c '[ "$(cat /usr/local/share/code-monkey/option-skills)" = "true" ]'

# Simulate entrypoint: first copy with defaults, then modify, then copy again with replace
export WORKSPACE_DIR="$(mktemp -d)"
export COPY_AGENT="true"
export COPY_SKILLS="true"
export WORKING_DIR="$WORKSPACE_DIR"

# --- First copy (no replace) ---
export REPLACE_EXISTING="false"
/usr/local/bin/copy-file-to-workspace "$WORKSPACE_DIR"

check "agent initially copied" test -f "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"

# Modify agent file to simulate user edits
echo "USER MODIFIED CONTENT" > "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"
check "agent file was modified" bash -c 'grep -q "USER MODIFIED CONTENT" "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"'

# --- Second copy without replace: should NOT overwrite ---
export REPLACE_EXISTING="false"
/usr/local/bin/copy-file-to-workspace "$WORKSPACE_DIR"

check "no-replace preserves user edits" bash -c 'grep -q "USER MODIFIED CONTENT" "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"'

# --- Third copy WITH replace: should overwrite ---
export REPLACE_EXISTING="true"
/usr/local/bin/copy-file-to-workspace "$WORKSPACE_DIR"

check "replace overwrites user edits" bash -c '! grep -q "USER MODIFIED CONTENT" "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"'
check "replace restores original content" bash -c 'grep -q "code-monkey" "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"'

rm -rf "$WORKSPACE_DIR"

reportResults
