#!/bin/bash
# Test: defaults (agent=true, skills=true, replaceExisting=false)
set -e

source dev-container-features-test-lib

# Verify install artifacts exist
check "install dir exists" test -d /usr/local/share/code-monkey
check "entrypoint exists" test -x /usr/local/share/code-monkey/entrypoint.sh
check "copy-file script exists" test -x /usr/local/bin/copy-file-to-workspace

# Verify agents were staged
check "agents dir staged" test -d /usr/local/share/code-monkey/agents
check "agent file staged" test -f /usr/local/share/code-monkey/agents/code-monkey.agent.md

# Verify skills were staged
check "skills dir staged" test -d /usr/local/share/code-monkey/skills

# Verify option files contain correct defaults
check "replace-existing default is false" bash -c '[ "$(cat /usr/local/share/code-monkey/replace-existing)" = "false" ]'
check "option-agent default is true" bash -c '[ "$(cat /usr/local/share/code-monkey/option-agent)" = "true" ]'
check "option-skills default is true" bash -c '[ "$(cat /usr/local/share/code-monkey/option-skills)" = "true" ]'

reportResults
