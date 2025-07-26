#!/bin/sh
set -e

SCHEDULE="${CRON_SCHEDULE:-0 3 * * *}"

echo "$SCHEDULE /usr/local/bin/backup.sh" > /etc/crontabs/root

exec crond -f -L /dev/stdout
