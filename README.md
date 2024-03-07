# DirBackup Local

[![Docker Pulls](https://img.shields.io/docker/pulls/ssedov/dirbackup-local)](https://hub.docker.com/r/ssedov/dirbackup-local)

-----------
Create an archive from the /data (mounted volume) and copy it to /backup (mounted volume). 

## Important notes

## Usage

### Build and push

Edit APP_NAME and TAG in Makefile and run:
```shell
make build
```

### Basic usage

Use the following command to start backup and copy to LOCAL backet:
```shell
docker run --rm -v /data/web:/data:ro /mnt/storage:/backup:ro\
  -e BACKUP_FORMAT='xz' \
  -e BACKUP_EXCLUDE='ansible,roles,collections,.terraform,.DS_Store,node_modules,*.log' \
  -e BACKUP_NAME=files \
  -e LOCAL_PATH=data \
  -e LOCAL_NAME_PREFIX=data \
  ssedov/dirbackup-local
```

## Environment variables

The following environment variables allows you to control the configuration parameters.

- `BACKUP_DIR` is the directory within the mounted volume to be archived; defaults to the root directory '/'.
- `BACKUP_NAME` is the name of the backup archive; the default name is set to 'data'.
- `BACKUP_EXCLUDE` is a comma-separated list of items to be excluded from the backup with no spaces; it defaults to an empty string.
- `BACKUP_FORMAT` specifies the archiving utility to be used, which can be either 'gzip' or 'xz'; 'gzip' is the default setting.
- `LOCAL_PATH` is the path within the local catalog where the archive will be stored; it defaults to an empty string.
- `LOCAL_NAME_PREFIX` is the prefix for the archive name; it defaults to an empty string.
