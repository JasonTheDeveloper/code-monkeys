#!/bin/bash
# Test: no_copy (agent=false, skills=false)
set -e

source dev-container-features-test-lib

# Verify install artifacts still exist (feature is installed, just nothing is copied)
check "install dir exists" test -d /usr/local/share/code-monkey
check "entrypoint exists" test -x /usr/local/share/code-monkey/entrypoint.sh
check "copy-file script exists" test -x /usr/local/bin/copy-file-to-workspace

# Verify option files reflect no_copy scenario
check "option-agent is false" bash -c '[ "$(cat /usr/local/share/code-monkey/option-agent)" = "false" ]'
check "option-skills is false" bash -c '[ "$(cat /usr/local/share/code-monkey/option-skills)" = "false" ]'

# Simulate entrypoint behavior: nothing should be copied
WORKSPACE_DIR="$(mktemp -d)"
export REPLACE_EXISTING="false"
export COPY_AGENT="false"
export COPY_SKILLS="false"
export WORKING_DIR="$WORKSPACE_DIR"

/usr/local/bin/copy-file-to-workspace "$WORKSPACE_DIR"

check "agents dir NOT created" bash -c '[ ! -d "$WORKSPACE_DIR/.github/agents" ]'
check "skills dir NOT created" bash -c '[ ! -d "$WORKSPACE_DIR/.github/skills" ]'
check ".github dir NOT created" bash -c '[ ! -d "$WORKSPACE_DIR/.github" ]'

rm -rf "$WORKSPACE_DIR"

reportResults
