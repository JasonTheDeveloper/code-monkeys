#!/bin/sh
set -e

# Create a place to store the template
mkdir -p /usr/local/share/code-monkey/
cp code-monkey.md /usr/local/share/code-monkey/code-monkey.md

# Copy the helper script
cp copy-file.sh /usr/local/bin/copy-file-to-workspace
chmod +x /usr/local/bin/copy-file-to-workspace

# Copy the entrypoint script
cp entrypoint.sh /usr/local/share/code-monkey/entrypoint.sh
chmod +x /usr/local/share/code-monkey/entrypoint.sh
