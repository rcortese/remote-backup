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

SSH_DIR="/root/.ssh"
if [ -z "${SSH_KEY_FILE}" ]; then
  SSH_KEY_FILE=$(find "$SSH_DIR" -maxdepth 1 -type f -name 'id_*' ! -name '*.pub' 2>/dev/null | head -n 1 || true)
fi

if [ ! -f "$SSH_KEY_FILE" ]; then
  printf '%s - ERROR: No SSH private key found in %s\n' "$(date)" "$SSH_DIR" >&2
  exit 1
fi

printf '%s - Validating SSH connectivity to %s using %s...\n' "$(date)" "$REMOTE_HOST" "$SSH_KEY_FILE"
if ! ssh -i "$SSH_KEY_FILE" -o BatchMode=yes -o ConnectTimeout=10 root@${REMOTE_HOST} true; then
  printf '%s - ERROR: Unable to connect to %s via SSH.\n' "$(date)" "$REMOTE_HOST" >&2
  exit 1
fi

printf '%s - Starting rsync...\n' "$(date)"
rsync -avz --delete -e "ssh -i ${SSH_KEY_FILE}" "$SOURCE" "$DEST"
