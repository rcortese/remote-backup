# Remote Backup Container

This repository provides a lightweight Docker image based on Alpine that performs a daily backup. Each subfolder under `/data/source` is compressed into a dated `tar.gz` archive and transferred using `rsync`. The destination can retain a configurable number of archives per subfolder, deleting the oldest ones when `BACKUP_KEEP` is greater than zero. The default is `0`, meaning no limit and nothing is removed.

## Project structure

- **Dockerfile** - Builds the image with `rsync` and `openssh-client`, copies the backup script and the entrypoint that sets up `cron`.
- **backup.sh** - Script that validates the SSH connection, compresses each subfolder and transfers the files with `rsync`, reading the variables defined in `backup.conf`.
- **entrypoint.sh** - Configures `cron` using the `CRON_SCHEDULE` variable and starts the service.
- **docker-compose.yml** - Helps create the container and map volumes.
- **backup.conf** - Configuration file with the environment variables used by `backup.sh`.

## Quick start

1. Copy the data you wish to synchronize to `./data/source`.
2. Adjust `backup.conf` with the desired remote host, user and path.
3. Place an SSH private key inside `./.ssh` (for example `id_rsa` or `id_ed25519`) with access to the target host.
4. Build and start the container:

   ```bash
   docker compose up --build -d
   ```

The container will execute `backup.sh` daily, which compresses each subfolder and sends the files to the destination while logging its output to the console.

## Customization

Edit `backup.conf` to define the variables `REMOTE_HOST`, `REMOTE_PATH` and optionally `REMOTE_USER`, as well as `BACKUP_KEEP` if you want to change how many archives are retained per subfolder. The default value is `0`, meaning unlimited retention. `REMOTE_USER` defaults to `root` when not set. The values in the repository are examples only. The file is mounted in the container and automatically read by `backup.sh` during each run.

You can also adjust how often the backup runs by setting the `CRON_SCHEDULE` environment variable. The default is `0 3 * * *`, which means daily at 3 a.m. This variable can be changed in `docker-compose.yml` or when starting the container.

## Configuration variables

The following variables can be defined in `backup.conf` or as environment variables:

- `REMOTE_HOST` – Hostname or IP of the destination server.
- `REMOTE_PATH` – Target directory on the remote server.
- `REMOTE_USER` – Remote user used for SSH (default: `root`).
- `BACKUP_KEEP` – Number of archives to keep for each subfolder. Use `0` for unlimited retention.
- `SSH_KEY_FILE` – Path to the SSH private key to use. If not set, the script searches `/root/.ssh` for the first available key.
- `CONFIG_FILE` – Path to an alternative configuration file (default: `/config/backup.conf`).
- `CRON_SCHEDULE` – Cron expression controlling when the backup runs (default: `0 3 * * *`).
