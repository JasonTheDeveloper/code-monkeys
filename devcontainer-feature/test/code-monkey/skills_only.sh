#!/bin/bash
# Test: skills_only (agent=false, skills=true)
set -e

source dev-container-features-test-lib

# Verify install artifacts exist
check "install dir exists" test -d /usr/local/share/code-monkey
check "entrypoint exists" test -x /usr/local/share/code-monkey/entrypoint.sh

# Verify option files reflect skills_only scenario
check "option-agent is false" bash -c '[ "$(cat /usr/local/share/code-monkey/option-agent)" = "false" ]'
check "option-skills is true" bash -c '[ "$(cat /usr/local/share/code-monkey/option-skills)" = "true" ]'
check "replace-existing is false" bash -c '[ "$(cat /usr/local/share/code-monkey/replace-existing)" = "false" ]'

# Verify skills were staged
check "skills dir staged" test -d /usr/local/share/code-monkey/skills

# Simulate entrypoint behavior
WORKSPACE_DIR="$(mktemp -d)"
export REPLACE_EXISTING="false"
export COPY_AGENT="false"
export COPY_SKILLS="true"
export WORKING_DIR="$WORKSPACE_DIR"

/usr/local/bin/copy-file-to-workspace "$WORKSPACE_DIR"

check "agents dir NOT created" bash -c '[ ! -d "$WORKSPACE_DIR/.github/agents" ]'
check "skills copied to workspace" test -d "$WORKSPACE_DIR/.github/skills"

# Verify at least some skill directories were copied
check "web-vulnerabilities skill exists" test -d "$WORKSPACE_DIR/.github/skills/web-vulnerabilities"
check "docker-vulnerabilities skill exists" test -d "$WORKSPACE_DIR/.github/skills/docker-vulnerabilities"

rm -rf "$WORKSPACE_DIR"

reportResults
