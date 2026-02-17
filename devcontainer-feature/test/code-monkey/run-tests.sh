#!/bin/bash
# Self-contained test runner for the code-monkey devcontainer feature.
# Simulates install.sh + copy-file.sh behavior and validates all option
# combinations without requiring the devcontainer CLI or a nested container.
#
# The copy-file.sh script uses hardcoded paths under /usr/local/share/code-monkey/,
# so this test installs to those real paths (backing up any pre-existing install)
# and restores the original state on exit.
#
# Usage: ./run-tests.sh
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")/../../src/code-monkey" && pwd)"
INSTALL_DIR="/usr/local/share/code-monkey"
INSTALL_BIN="/usr/local/bin/copy-file-to-workspace"
BACKUP_DIR=""
PASSED=0
FAILED=0

# ── helpers ──────────────────────────────────────────────────────────────
green()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
red()    { printf '\033[1;31m%s\033[0m\n' "$*"; }
header() { printf '\n\033[1;36m━━━ %s ━━━\033[0m\n' "$*"; }

check() {
    local label="$1"; shift
    if "$@" >/dev/null 2>&1; then
        green "  ✓ $label"
        PASSED=$((PASSED + 1))
    else
        red "  ✗ $label"
        FAILED=$((FAILED + 1))
    fi
}

# Back up any existing installation so we can restore it later
backup_existing() {
    BACKUP_DIR="$(mktemp -d)"
    if [ -d "$INSTALL_DIR" ]; then
        cp -a "$INSTALL_DIR" "$BACKUP_DIR/code-monkey"
    fi
    if [ -f "$INSTALL_BIN" ]; then
        cp -a "$INSTALL_BIN" "$BACKUP_DIR/copy-file-to-workspace"
    fi
}

# Restore the original installation (or remove if there wasn't one)
restore_existing() {
    rm -rf "$INSTALL_DIR"
    rm -f  "$INSTALL_BIN"
    if [ -n "$BACKUP_DIR" ]; then
        if [ -d "$BACKUP_DIR/code-monkey" ]; then
            cp -a "$BACKUP_DIR/code-monkey" "$INSTALL_DIR"
        fi
        if [ -f "$BACKUP_DIR/copy-file-to-workspace" ]; then
            cp -a "$BACKUP_DIR/copy-file-to-workspace" "$INSTALL_BIN"
        fi
        rm -rf "$BACKUP_DIR"
    fi
}
trap restore_existing EXIT

# Install the feature to the real paths with the given options
install_feature() {
    local opt_agent="${1:-true}"
    local opt_skills="${2:-true}"
    local opt_replace="${3:-false}"

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    # Copy agents
    if [ -d "$FEATURE_DIR/agents" ]; then
        cp -r "$FEATURE_DIR/agents" "$INSTALL_DIR/agents"
    fi
    # Copy skills
    if [ -d "$FEATURE_DIR/skills" ]; then
        cp -r "$FEATURE_DIR/skills" "$INSTALL_DIR/skills"
    fi
    # Copy helper script
    cp "$FEATURE_DIR/copy-file.sh" "$INSTALL_BIN"
    chmod +x "$INSTALL_BIN"

    # Persist options
    echo "$opt_replace" > "$INSTALL_DIR/replace-existing"
    echo "$opt_agent"   > "$INSTALL_DIR/option-agent"
    echo "$opt_skills"  > "$INSTALL_DIR/option-skills"

    # Copy entrypoint
    cp "$FEATURE_DIR/entrypoint.sh" "$INSTALL_DIR/entrypoint.sh"
    chmod +x "$INSTALL_DIR/entrypoint.sh"
}

# Run copy-file-to-workspace against a workspace directory
run_copy() {
    local workspace="$1"
    local replace="$2"
    local agent="$3"
    local skills="$4"

    REPLACE_EXISTING="$replace" \
    COPY_AGENT="$agent" \
    COPY_SKILLS="$skills" \
    WORKING_DIR="$workspace" \
    /bin/sh "$INSTALL_BIN" "$workspace"
}

# ── setup ────────────────────────────────────────────────────────────────
backup_existing

# ── test: defaults ───────────────────────────────────────────────────────
test_defaults() {
    header "Scenario: defaults (agent=true, skills=true, replaceExisting=false)"
    install_feature true true false

    check "install dir exists"           test -d "$INSTALL_DIR"
    check "entrypoint is executable"     test -x "$INSTALL_DIR/entrypoint.sh"
    check "copy-file script executable"  test -x "$INSTALL_BIN"
    check "agents dir staged"            test -d "$INSTALL_DIR/agents"
    check "agent file staged"            test -f "$INSTALL_DIR/agents/code-monkey.agent.md"
    check "skills dir staged"            test -d "$INSTALL_DIR/skills"
    check "option-agent is true"         bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-agent")" = "true" ]'
    check "option-skills is true"        bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-skills")" = "true" ]'
    check "replace-existing is false"    bash -c '[ "$(cat "'"$INSTALL_DIR"'/replace-existing")" = "false" ]'

    local ws; ws="$(mktemp -d)"
    run_copy "$ws" false true true
    check "agent copied to workspace"    test -f "$ws/.github/agents/code-monkey.agent.md"
    check "skills copied to workspace"   test -d "$ws/.github/skills"
    check "web-vuln skill exists"        test -d "$ws/.github/skills/web-vulnerabilities"

    rm -rf "$ws"
}

# ── test: agent only ────────────────────────────────────────────────────
test_agent_only() {
    header "Scenario: agent_only (agent=true, skills=false)"
    install_feature true false false

    check "option-agent is true"   bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-agent")" = "true" ]'
    check "option-skills is false" bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-skills")" = "false" ]'

    local ws; ws="$(mktemp -d)"
    run_copy "$ws" false true false
    check "agent copied"           test -f "$ws/.github/agents/code-monkey.agent.md"
    check "skills dir NOT created" bash -c '[ ! -d "'"$ws"'/.github/skills" ]'

    rm -rf "$ws"
}

# ── test: skills only ───────────────────────────────────────────────────
test_skills_only() {
    header "Scenario: skills_only (agent=false, skills=true)"
    install_feature false true false

    check "option-agent is false" bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-agent")" = "false" ]'
    check "option-skills is true" bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-skills")" = "true" ]'

    local ws; ws="$(mktemp -d)"
    run_copy "$ws" false false true
    check "agents dir NOT created"         bash -c '[ ! -d "'"$ws"'/.github/agents" ]'
    check "skills copied"                  test -d "$ws/.github/skills"
    check "docker-vuln skill exists"       test -d "$ws/.github/skills/docker-vulnerabilities"
    check "cicd-vuln skill exists"         test -d "$ws/.github/skills/cicd-vulnerabilities"

    rm -rf "$ws"
}

# ── test: no copy ────────────────────────────────────────────────────────
test_no_copy() {
    header "Scenario: no_copy (agent=false, skills=false)"
    install_feature false false false

    check "option-agent is false"  bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-agent")" = "false" ]'
    check "option-skills is false" bash -c '[ "$(cat "'"$INSTALL_DIR"'/option-skills")" = "false" ]'

    local ws; ws="$(mktemp -d)"
    run_copy "$ws" false false false
    check "agents dir NOT created" bash -c '[ ! -d "'"$ws"'/.github/agents" ]'
    check "skills dir NOT created" bash -c '[ ! -d "'"$ws"'/.github/skills" ]'
    check ".github dir NOT created" bash -c '[ ! -d "'"$ws"'/.github" ]'

    rm -rf "$ws"
}

# ── test: replace existing ──────────────────────────────────────────────
test_replace_existing() {
    header "Scenario: replace_existing (replaceExisting=true)"
    install_feature true true true

    check "replace-existing is true" bash -c '[ "$(cat "'"$INSTALL_DIR"'/replace-existing")" = "true" ]'

    local ws; ws="$(mktemp -d)"

    # First copy
    run_copy "$ws" false true true
    check "agent initially copied" test -f "$ws/.github/agents/code-monkey.agent.md"

    # Simulate user modification
    echo "USER MODIFIED CONTENT" > "$ws/.github/agents/code-monkey.agent.md"

    # Copy again WITHOUT replace — user edits should be preserved
    run_copy "$ws" false true true
    check "no-replace preserves user edits" grep -q "USER MODIFIED CONTENT" "$ws/.github/agents/code-monkey.agent.md"

    # Copy again WITH replace — user edits should be overwritten
    run_copy "$ws" true true true
    check "replace overwrites user edits" bash -c '! grep -q "USER MODIFIED CONTENT" "'"$ws"'/.github/agents/code-monkey.agent.md"'
    check "replace restores original"     grep -q "code-monkey" "$ws/.github/agents/code-monkey.agent.md"

    rm -rf "$ws"
}

# ── test: workspace detection ────────────────────────────────────────────
test_workspace_detection() {
    header "Scenario: workspace directory detection fallbacks"
    install_feature true false false

    # Test with explicit argument
    local ws; ws="$(mktemp -d)"
    run_copy "$ws" false true false
    check "explicit arg: agent copied" test -f "$ws/.github/agents/code-monkey.agent.md"

    # Test with WORKING_DIR env var (no argument)
    local ws2; ws2="$(mktemp -d)"
    REPLACE_EXISTING="false" COPY_AGENT="true" COPY_SKILLS="false" WORKING_DIR="$ws2" \
        /bin/sh "$INSTALL_BIN"
    check "WORKING_DIR fallback: agent copied" test -f "$ws2/.github/agents/code-monkey.agent.md"

    rm -rf "$ws" "$ws2"
}

# ── run all tests ────────────────────────────────────────────────────────
test_defaults
test_agent_only
test_skills_only
test_no_copy
test_replace_existing
test_workspace_detection

# ── summary ──────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAILED" -eq 0 ]; then
    green "All $PASSED tests passed!"
else
    red "$FAILED test(s) failed out of $((PASSED + FAILED))"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit "$FAILED"
