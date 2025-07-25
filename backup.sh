#!/bin/sh
set -e

# Load configuration file if available. The default location
# can be overridden via the CONFIG_FILE environment variable.
CONFIG_FILE="${CONFIG_FILE:-/config/backup.conf}"
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  . "$CONFIG_FILE"
fi

SOURCE="/data/source/"

# Ensure required variables are defined.
: "${REMOTE_HOST:?Missing REMOTE_HOST}"
: "${REMOTE_PATH:?Missing REMOTE_PATH}"

DEST="root@${REMOTE_HOST}:${REMOTE_PATH}"

printf '%s - Validating SSH connectivity to %s...\n' "$(date)" "$REMOTE_HOST"
if ! ssh -i /root/.ssh/id_ed25519 -o BatchMode=yes -o ConnectTimeout=10 root@${REMOTE_HOST} true; then
  printf '%s - ERROR: Unable to connect to %s via SSH.\n' "$(date)" "$REMOTE_HOST" >&2
  exit 1
fi

printf '%s - Starting rsync...\n' "$(date)"
rsync -avz --delete -e "ssh -i /root/.ssh/id_ed25519" "$SOURCE" "$DEST"
