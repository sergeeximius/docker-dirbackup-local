# DirBackup S3cmd

[![Docker Pulls](https://img.shields.io/docker/pulls/ssedov/dirbackup-s3cmd)](https://hub.docker.com/r/ssedov/dirbackup-s3cmd)

-----------
Create an archive from the /data (mounted volume) and send it to S3 (using s3cmd). 

## Important notes
Use [xueshanf/awscli](https://hub.docker.com/r/xueshanf/awscli:latest)

## Usage

### Build and push

Edit APP_NAME and TAG in Makefile and run:
```shell
make build
```

### Basic usage

Use the following command to start backup and copy to S3 backet:
```shell
docker run --rm -v /data/web:/data:ro \
  -e BACKUP_FORMAT='xz' \
  -e BACKUP_EXCLUDE='ansible,roles,collections,.terraform,.DS_Store,node_modules,*.log' \
  -e BACKUP_NAME=files \
  -e S3_BACKET=web-backup \
  -e S3_PATH=data \
  -e S3_NAME_PREFIX=data \
  -e S3_ACCESS_KEY='access_key' \
  -e S3_SECRET_KEY='secret' \
  ssedov/dirbackup-s3cmd:2.1
```

## Environment variables

The following environment variables allows you to control the configuration parameters.

- `BACKUP_DIR` is the directory within the mounted volume to be archived; defaults to the root directory '/'.
- `BACKUP_NAME` is the name of the backup archive; the default name is set to 'data'.
- `BACKUP_EXCLUDE` is a comma-separated list of items to be excluded from the backup with no spaces; it defaults to an empty string.
- `BACKUP_FORMAT` specifies the archiving utility to be used, which can be either 'gzip' or 'xz'; 'gzip' is the default setting.
- `S3_BUCKET` is the mandatory name of the bucket within the S3 storage.
- `S3_ACCESS_KEY` is the required S3 access key credential.
- `S3_SECRET_KEY` is the required S3 secret key credential.
- `S3_PATH` is the path within the S3 bucket where the archive will be stored; it defaults to an empty string.
- `S3_NAME_PREFIX` is the prefix for the archive name; it defaults to an empty string.
- `S3_PROVIDER` is the S3 service provider, options include 'Yandex' or 'Selectel'; the default provider is set to 'yandex'.
