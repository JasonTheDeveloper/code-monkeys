#!/bin/bash
# filepath: scripts/smart-version-update.sh

set -euo pipefail

# Default values
README_FILE="README.md"
NEW_VERSION=""

usage() {
    echo "Usage: $0 <new_version> [readme_file]"
    echo ""
    echo "This script intelligently finds and replaces version strings in badge URLs."
    echo "Single dashes (-) in versions are converted to double dashes (--)."
    echo "Badge color suffixes (-blue, -green, etc.) are automatically preserved."
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0-beta.1    # Becomes: 1.0.0--beta.1-blue in badges"
    echo "  $0 2.0.0           # Becomes: 2.0.0-blue in badges"
    echo "  $0 1.5.0-rc.2 /path/to/README.md"
    exit 1
}

# Parse arguments
if [ $# -lt 1 ]; then
    usage
fi

NEW_VERSION="$1"
if [ $# -ge 2 ]; then
    README_FILE="$2"
fi

# Validate inputs
if [ ! -f "$README_FILE" ]; then
    echo "Error: README file not found: $README_FILE"
    exit 1
fi

# Flexible version validation - supports both X.Y.Z and X.Y.Z-suffix
if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
    echo "Error: Invalid version format. Expected format: X.Y.Z or X.Y.Z-suffix"
    echo "Valid examples: 1.0.0, 2.1.0, 1.0.0-alpha.5, 2.1.0-beta.1, 3.0.0-rc.1"
    exit 1
fi

# Convert single dashes to double dashes for badge format
BADGE_VERSION=$(echo "$NEW_VERSION" | sed 's/-/--/g')

# Create backup
cp "$README_FILE" "${README_FILE}.bak"
echo "Created backup: ${README_FILE}.bak"

# Show current version patterns found
echo "Current version patterns found:"
grep -oE "(docker@latest-|version-|v)[^?]*" "$README_FILE" || echo "No standard version patterns found"

# Extract color suffix from docker badge if it exists
current_color_suffix=""
docker_badge=$(grep -oE "docker@latest-[^?]*" "$README_FILE" || echo "")
if [[ "$docker_badge" =~ docker@latest-[0-9]+\.[0-9]+\.[0-9]+(-{1,2}[a-zA-Z0-9.-]*)?(-[a-zA-Z]+)?$ ]]; then
    current_color_suffix=$(echo "$docker_badge" | sed -n 's/.*docker@latest-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\(-\{1,2\}[a-zA-Z0-9.-]*\)\?\(-[a-zA-Z]*\)$/\2/p')
fi

# Default to -blue if no color suffix found
if [ -z "$current_color_suffix" ]; then
    current_color_suffix="-blue"
fi

# Build the new badge version with preserved color
NEW_BADGE_VERSION="${BADGE_VERSION}${current_color_suffix}"

# Replace different version patterns
# Pattern 1: docker@latest-X.X.X (with preserved color suffix)
sed -i.tmp1 "s|docker@latest-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\(-\{1,2\}[a-zA-Z0-9.-]*\)\?\(-[a-zA-Z]*\)\?|docker@latest-${NEW_BADGE_VERSION}|g" "$README_FILE"

# Pattern 2: version-X.X.X (keeping single dashes for other contexts)
sed -i.tmp2 "s|version-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\(-[a-zA-Z0-9.-]*\)\?|version-${NEW_VERSION}|g" "$README_FILE"

# Pattern 3: vX.X.X (keeping single dashes for other contexts)
sed -i.tmp3 "s|v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\(-[a-zA-Z0-9.-]*\)\?|v${NEW_VERSION}|g" "$README_FILE"

# Clean up temporary files
rm -f "${README_FILE}".tmp*

# Show what changed
echo ""
echo "Input version: ${NEW_VERSION}"
echo "Badge version (with double dashes + color): ${NEW_BADGE_VERSION}"
echo ""
echo "Updated lines:"
grep -E "(docker@latest-|version-|v)" "$README_FILE" || echo "Warning: Could not find updated patterns in file"

echo ""
echo "Update complete!"
