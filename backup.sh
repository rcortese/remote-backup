#!/bin/sh
set -e

# Load configuration file if available. The default location
# can be overridden via the CONFIG_FILE environment variable.
CONFIG_FILE="${CONFIG_FILE:-/config/backup.conf}"
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  . "$CONFIG_FILE"
fi

SOURCE="/data/source"

# Ensure required variables are defined.
: "${REMOTE_HOST:?Missing REMOTE_HOST}"
: "${REMOTE_PATH:?Missing REMOTE_PATH}"

DEST="root@${REMOTE_HOST}:${REMOTE_PATH}"

# Number of backups to keep per subfolder. Older archives will be
# deleted after each new backup when this value is greater than zero.
# Can be set via BACKUP_KEEP or in the configuration file. Defaults to 0
# meaning unlimited retention.
BACKUP_KEEP="${BACKUP_KEEP:-0}"

SSH_DIR="/root/.ssh"
if [ -z "${SSH_KEY_FILE}" ]; then
  SSH_KEY_FILE=$(find "$SSH_DIR" -maxdepth 1 -type f -name 'id_*' ! -name '*.pub' 2>/dev/null | head -n 1 || true)
fi

if [ ! -f "$SSH_KEY_FILE" ]; then
  printf '%s - ERROR: No SSH private key found in %s\n' "$(date)" "$SSH_DIR" >&2
  exit 1
fi

printf '%s - Validating SSH connectivity to %s using %s...\n' "$(date)" "$REMOTE_HOST" "$SSH_KEY_FILE"
if ! ssh -i "$SSH_KEY_FILE" -o BatchMode=yes -o ConnectTimeout=10 "root@${REMOTE_HOST}" true; then
  printf '%s - ERROR: Unable to connect to %s via SSH.\n' "$(date)" "$REMOTE_HOST" >&2
  exit 1
fi

printf '%s - Ensuring remote directory %s exists...\n' "$(date)" "$REMOTE_PATH"
ssh -i "$SSH_KEY_FILE" "root@${REMOTE_HOST}" "mkdir -p \"${REMOTE_PATH}\""

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

for dir in "$SOURCE"/*; do
  [ -d "$dir" ] || continue
  base=$(basename "$dir")
  archive="${TMP_DIR}/${base}_$(date +%Y%m%d).tar.gz"
  printf '%s - Creating archive %s...\n' "$(date)" "$archive"
  tar -czf "$archive" -C "$SOURCE" "$base"
  printf '%s - Transferring %s to %s...\n' "$(date)" "$archive" "$DEST/"
  rsync -avz -e "ssh -i ${SSH_KEY_FILE}" "$archive" "$DEST/"

  if [ "$BACKUP_KEEP" -gt 0 ]; then
    printf '%s - Pruning old backups for %s, keeping %s files...\n' "$(date)" "$base" "$BACKUP_KEEP"
    ssh -i "$SSH_KEY_FILE" "root@${REMOTE_HOST}" \
      "cd \"${REMOTE_PATH}\" && ls -1 ${base}_*.tar.gz 2>/dev/null | sort | head -n -${BACKUP_KEEP} | xargs -r rm -f"
  fi
done
