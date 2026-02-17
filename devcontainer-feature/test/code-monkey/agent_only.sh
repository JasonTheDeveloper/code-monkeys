#!/bin/bash
# Test: agent_only (agent=true, skills=false)
set -e

source dev-container-features-test-lib

# Verify install artifacts exist
check "install dir exists" test -d /usr/local/share/code-monkey
check "entrypoint exists" test -x /usr/local/share/code-monkey/entrypoint.sh

# Verify option files reflect agent_only scenario
check "option-agent is true" bash -c '[ "$(cat /usr/local/share/code-monkey/option-agent)" = "true" ]'
check "option-skills is false" bash -c '[ "$(cat /usr/local/share/code-monkey/option-skills)" = "false" ]'
check "replace-existing is false" bash -c '[ "$(cat /usr/local/share/code-monkey/replace-existing)" = "false" ]'

# Verify agents were staged
check "agents dir staged" test -d /usr/local/share/code-monkey/agents
check "agent file staged" test -f /usr/local/share/code-monkey/agents/code-monkey.agent.md

# Simulate entrypoint behavior: run copy-file script and verify skills are NOT copied
WORKSPACE_DIR="$(mktemp -d)"
export REPLACE_EXISTING="false"
export COPY_AGENT="true"
export COPY_SKILLS="false"
export WORKING_DIR="$WORKSPACE_DIR"

/usr/local/bin/copy-file-to-workspace "$WORKSPACE_DIR"

check "agent copied to workspace" test -f "$WORKSPACE_DIR/.github/agents/code-monkey.agent.md"
check "skills dir NOT created" bash -c '[ ! -d "$WORKSPACE_DIR/.github/skills" ]'

rm -rf "$WORKSPACE_DIR"

reportResults
