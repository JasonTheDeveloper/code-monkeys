#!/bin/sh
set +e

# Read the replaceExisting option persisted at install time
REPLACE_EXISTING="$(cat /usr/local/share/code-monkey/replace-existing 2>/dev/null || echo false)"
export REPLACE_EXISTING

/usr/local/bin/copy-file-to-workspace > /tmp/code-monkey.log 2>&1
