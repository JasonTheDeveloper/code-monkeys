#!/bin/sh
# Target directory (defaulting to the workspace root)
TARGET_DIR="${1:-${containerWorkspaceFolder:-/workspaces/default}}"

mkdir -p "$TARGET_DIR/.github/agents/"
cp -n /usr/local/share/code-monkey/code-monkey.md "$TARGET_DIR/.github/agents/code-monkey.md"
