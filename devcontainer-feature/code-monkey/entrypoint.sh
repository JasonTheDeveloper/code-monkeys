#!/bin/sh
set -e

# Run the copy script
/usr/local/bin/copy-file-to-workspace

# Execute the command passed to the container
exec "$@"
