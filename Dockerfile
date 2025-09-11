# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG RELURL=https://releases.hashicorp.com
ARG SRCARCH
ARG VERSION
#
ENV CONSUL_HOME=/consul
#
RUN set -ex \
    && apk add -Uu --no-cache \
        ca-certificates \
        curl \
        iputils \
        libc6-compat \
        libcap \
        tzdata \
    && (if [ ! -e /etc/nsswitch.conf ]; then echo 'hosts: files dns' > /etc/nsswitch.conf; fi) \
    && mkdir -p /tmp/consul \
    && cd /tmp/consul \
#
    && echo "Using consul: $SRCARCH $VERSION" \
    && curl \
        -o consul_${VERSION}_${SRCARCH}.zip \
        -SL ${RELURL}/consul/${VERSION}/consul_${VERSION}_${SRCARCH}.zip \
    && curl \
        -o consul_${VERSION}_SHA256SUMS \
        -SL ${RELURL}/consul/${VERSION}/consul_${VERSION}_SHA256SUMS \
#
    # fix old sha256sum single vs double spacing issue for alpine, newer version does not care about space
    # && sed -ie 's/ /  /' consul_${VERSION}_SHA256SUMS \
    && grep consul_${VERSION}_${SRCARCH}.zip consul_${VERSION}_SHA256SUMS \
        | sha256sum -c \
#
    && unzip -d /tmp/consul consul_${VERSION}_${SRCARCH}.zip \
    && mv consul /usr/local/bin/consul \
    && chmod +x /usr/local/bin/consul \
#
    && apk del --purge \
        curl \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME ${CONSUL_HOME}
#
EXPOSE 8300/tcp 8301/tcp 8301/udp 8302/tcp 8302/udp 8500/tcp 8501/tcp 8502/tcp 8503/tcp 8600 8600/udp
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:8500/"} || exit 1
#
ENTRYPOINT ["/init"]
