#!/bin/sh
set -e

# Create a place to store the template
mkdir -p /usr/local/share/code-monkey/

# Copy agents directory
if [ -d agents ]; then
	cp -r agents /usr/local/share/code-monkey/agents
fi

# Copy skills directory
if [ -d skills ]; then
	cp -r skills /usr/local/share/code-monkey/skills
fi

# Copy the helper script
cp copy-file.sh /usr/local/bin/copy-file-to-workspace
chmod +x /usr/local/bin/copy-file-to-workspace

# Persist options for use at container start
echo "${REPLACEEXISTING:-false}" > /usr/local/share/code-monkey/replace-existing
echo "${AGENT:-true}" > /usr/local/share/code-monkey/option-agent
echo "${SKILLS:-true}" > /usr/local/share/code-monkey/option-skills

# Copy the entrypoint script
cp entrypoint.sh /usr/local/share/code-monkey/entrypoint.sh
chmod +x /usr/local/share/code-monkey/entrypoint.sh
