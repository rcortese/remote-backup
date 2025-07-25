#!/bin/sh
set -e

REMOTE_HOST="10.18.19.2"
REMOTE_PATH="/mnt/user/backups/zbox"
SOURCE="/data/source/"
DEST="root@${REMOTE_HOST}:${REMOTE_PATH}"

printf '%s - Validating SSH connectivity to %s...\n' "$(date)" "$REMOTE_HOST"
if ! ssh -i /root/.ssh/id_ed25519 -o BatchMode=yes -o ConnectTimeout=10 root@${REMOTE_HOST} true; then
  printf '%s - ERROR: Unable to connect to %s via SSH.\n' "$(date)" "$REMOTE_HOST" >&2
  exit 1
fi

printf '%s - Starting rsync...\n' "$(date)"
rsync -avz --delete -e "ssh -i /root/.ssh/id_ed25519" "$SOURCE" "$DEST"
