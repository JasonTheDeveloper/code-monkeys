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
# Determine copy flags based on REPLACE_EXISTING
if [ "$REPLACE_EXISTING" = "true" ]; then
	CP_FLAGS=""
	echo "Copying Code Monkey files to $TARGET_DIR (replacing existing files)"
else
	CP_FLAGS="-n"
	echo "Copying Code Monkey files to $TARGET_DIR (skipping existing files)"
fi

mkdir -p "$TARGET_DIR/.github/agents/"
cp $CP_FLAGS /usr/local/share/code-monkey/code-monkey.md "$TARGET_DIR/.github/agents/code-monkey.md"

# Copy skills to .github/skills/
if [ -d /usr/local/share/code-monkey/skills ]; then
	mkdir -p "$TARGET_DIR/.github/skills/"
	cp -r $CP_FLAGS /usr/local/share/code-monkey/skills/* "$TARGET_DIR/.github/skills/"
	echo "Copied skills to $TARGET_DIR/.github/skills/"
fi
