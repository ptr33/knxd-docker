# knxd-docker

Build the container with specific version of KNXD. The container is using a multi-stage build, which
reduces the final container size from 414 MBytes to 16.5 MBytes.

```bash
docker build -t ptr33/knxd-docker --build-arg KNXD_VERSION=0.14.72 .
```

The container is automatically built using GitHub actions and published on ghcr.io in https://github.com/ptr33/knxd-docker/pkgs/container/knxd-docker

Run knxd in docker container

```bash
docker run \
--name=knxd \
-p 6720:6720/tcp -p 3671:3671/udp \
--device=/dev/bus/usb:/dev/bus/usb:rwm \
--device=/dev/mem:/dev/mem:rw \
--device=/dev/knx:/dev/knx \
--cap-add=SYS_MODULE --cap-add=SYS_RAWIO \
--restart unless-stopped ghcr.io/ptr33/knxd-docker
```

Test the knx server by login to the container and run e.g.
`knxtool groupswrite ip:localhost 0/0/20 0`
