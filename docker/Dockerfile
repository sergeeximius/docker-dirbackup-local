FROM alpine:3

# Labels.
LABEL maintainer="serge.eximius@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="ssedov/dirbackup-local" \
    org.label-schema.description="Dockerized file backup with copy to local storage." \
    org.label-schema.url="https://github.com/sergeeximius/docker-dirbackup-local" \
    org.label-schema.vcs-url="https://github.com/sergeeximius/docker-dirbackup-local" \
    org.label-schema.vendor="Sergey Sedov" \
    org.label-schema.docker.cmd="docker run -it ssedov/dirbackup-local:latest"

RUN apk --no-cache add bash xz coreutils
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
