#!/bin/sh
# Target directory (defaulting to the workspace root)
TARGET_DIR="${1:-${WORKING_DIR:-}}"

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
	if [ -n "$WORKSPACE_FOLDER" ] && [ -d "$WORKSPACE_FOLDER" ]; then
		TARGET_DIR="$WORKSPACE_FOLDER"
	fi
fi

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
	if [ -n "$containerWorkspaceFolder" ] && [ -d "$containerWorkspaceFolder" ]; then
		TARGET_DIR="$containerWorkspaceFolder"
	fi
fi

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
	if [ -d /workspaces ]; then
		set -- /workspaces/*
		if [ "$#" -eq 1 ] && [ -d "$1" ]; then
			TARGET_DIR="$1"
		fi
	fi
fi

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
	TARGET_DIR="$(pwd)"
fi
echo "Copying Code Monkey agent file to $TARGET_DIR/.github/agents/"

mkdir -p "$TARGET_DIR/.github/agents/"
cp -n /usr/local/share/code-monkey/code-monkey.md "$TARGET_DIR/.github/agents/code-monkey.md"
