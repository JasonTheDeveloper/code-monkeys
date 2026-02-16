#!/bin/sh
set +e

# Read options persisted at install time
REPLACE_EXISTING="$(cat /usr/local/share/code-monkey/replace-existing 2>/dev/null || echo false)"
COPY_AGENT="$(cat /usr/local/share/code-monkey/option-agent 2>/dev/null || echo true)"
COPY_SKILLS="$(cat /usr/local/share/code-monkey/option-skills 2>/dev/null || echo true)"
export REPLACE_EXISTING COPY_AGENT COPY_SKILLS

/usr/local/bin/copy-file-to-workspace > /tmp/code-monkey.log 2>&1
