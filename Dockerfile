FROM alpine:3.22 AS builder

ENV LANG=C.UTF-8
RUN set -xe \
    && apk update \
    && apk add --no-cache --virtual .build-dependencies \
                git \
                abuild \
                binutils \
                build-base \
                automake \
                autoconf \
                argp-standalone \
                linux-headers \
                libev-dev \
                libusb-dev \
                cmake \
                dev86 \ 
                gcc
RUN set -xe \
     && apk add --no-cache \
                udev \
                bash \ 
                libusb \
                libev \
                libgcc \
                libstdc++ \
                libtool
# ARG is in my Synology Docker version not working - yet
#ARG KNXD_VERSION
#RUN git clone --branch "$KNXD_VERSION" --depth 1 https://github.com/knxd/knxd.git \
RUN git clone --branch "0.14.72" --depth 1 https://github.com/knxd/knxd.git \
     && cd knxd \
     && chmod 777 ./bootstrap.sh \
     && ./bootstrap.sh \
     && ./configure --disable-systemd --enable-tpuart --enable-usb --enable-eibnetipserver --enable-eibnetip --enable-eibnetserver --enable-eibnetiptunnel \
     && mkdir -p src/include/sys && ln -s /usr/lib/bcc/include/sys/cdefs.h src/include/sys \
     && make \
     && make DESTDIR=/install install \
     && make clean \
     && cd .. \
     && rm -rf knxd
# RUN apk del --purge .build-dependencies

# Strip binaries to reduce size
RUN  find /install -type f -executable -exec strip --strip-unneeded {} + 2>/dev/null || true

## list all files and stop - only used for development
#RUN cd /install \
#    && find . \
#    && pause

# Runtime stage - minimal image with only runtime dependencies
FROM alpine:3.22

# Install only runtime dependencies
RUN set -xe && \
    apk update && \
    apk add --no-cache \
        # Core runtime libraries
        libev \
        libusb \
        libgcc \
        libstdc++

# copy knxd configuration
COPY knxd.ini /etc/

# Copy knxd binaries and libraries from builder stage
COPY --from=builder /install/ /

# create missing directories and check if we can execute the daemon
RUN mkdir -p /var/log/knxd /var/run/knxd && \
    /usr/local/bin/knxd --help

ENTRYPOINT ["knxd", "/etc/knxd.ini"]
