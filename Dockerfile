FROM alpine:3.18

RUN apk --no-cache add \
    git \
    gnupg && \
    rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
