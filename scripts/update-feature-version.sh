#!/bin/bash

set -euo pipefail

# Check if a version number is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <new_version>"
    exit 1
fi

NEW_VERSION="$1"
target_file="devcontainer-feature/code-monkey/devcontainer-feature.json"

# Resolve the file path
if [ -f "$target_file" ]; then
    JSON_FILE="$target_file"
else
    # Try finding it relative to script location
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    JSON_FILE="$SCRIPT_DIR/../$target_file"
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: Could not find $target_file"
    exit 1
fi

echo "Updating version to $NEW_VERSION in $JSON_FILE..."

# Update version using sed
# Note: This regex assumes "version": "value" format matches standard JSON formatting
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed requires an empty string argument for -i
    sed -i '' "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$JSON_FILE"
else
    sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$JSON_FILE"
fi

echo "Successfully updated version."
