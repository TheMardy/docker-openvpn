# Multiplatform OpenVPN for Docker

[![Version](https://img.shields.io/github/v/tag/themardy/docker-openvpn?label=version&style=flat-square)](https://github.com/TheMardy/docker-openvpn/releases)
![Travis (.org)](https://img.shields.io/travis/themardy/docker-openvpn)
[![Actions Status](https://github.com/themardy/docker-openvpn/workflows/build/badge.svg)](https://github.com/themardy/docker-openvpn/actions)
[![Docker Stars](https://img.shields.io/docker/stars/themardy/openvpn.svg)](https://hub.docker.com/r/themardy/openvpn/)
[![Docker Pulls](https://img.shields.io/docker/pulls/themardy/openvpn.svg)](https://hub.docker.com/r/themardy/openvpn/)
[![ImageLayers](https://images.microbadger.com/badges/image/themardy/openvpn.svg)](https://microbadger.com/#/images/themardy/openvpn)

## About
Original Credits: [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn)

🐳 Multiplatform OpenVPN server in a Docker container complete with an EasyRSA PKI CA.

### Supported platforms
| Platform  | Tested |
| ------------- | ------------- |
| linux/amd64  | ✓  |
| linux/arm/v6  | -  |
| linux/arm/v7  | ✓  |
| linux/arm64  | -  |
| linux/386  | -  |
| linux/ppc64le  | -  |

Please [raise an issue 💬](https://github.com/TheMardy/docker-openvpn/issues) if you are able to test an untested platform 🙏

# Quick Start with docker-compose

* Add a new service in docker-compose.yml

```yaml
version: '2'
services:
  openvpn:
    cap_add:
     - NET_ADMIN
    image: themardy/openvpn
    container_name: openvpn
    ports:
     - "1194:1194/udp"
    restart: always
    volumes:
     - ./openvpn-data/conf:/etc/openvpn
```


* Initialize the configuration files and certificates

```bash
docker-compose run --rm openvpn ovpn_genconfig -u udp://VPN.SERVERNAME.COM
docker-compose run --rm openvpn ovpn_initpki
```

* Fix ownership (depending on how to handle your backups, this may not be needed)

```bash
sudo chown -R $(whoami): ./openvpn-data
```

* Start OpenVPN server process

```bash
docker-compose up -d openvpn
```

* You can access the container logs with

```bash
docker-compose logs -f
```

* Generate a client certificate

```bash
export CLIENTNAME="your_client_name"
# with a passphrase (recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME
# without a passphrase (not recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass
```

* Retrieve the client configuration with embedded certificates

```bash
docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
```

* Revoke a client certificate

```bash
# Keep the corresponding crt, key and req files.
docker-compose run --rm openvpn ovpn_revokeclient $CLIENTNAME
# Remove the corresponding crt, key and req files.
docker-compose run --rm openvpn ovpn_revokeclient $CLIENTNAME remove
```

## Debugging Tips

* Create an environment variable with the name DEBUG and value of 1 to enable debug output (using "docker -e").

```bash
docker-compose run -e DEBUG=1 -p 1194:1194/udp openvpn
```

# Quick Start with docker run

* Pick a name for the `$OVPN_DATA` data volume container. It's recommended to
  use the `ovpn-data-` prefix to operate seamlessly with the reference systemd
  service.  Users are encourage to replace `example` with a descriptive name of
  their choosing.

      OVPN_DATA="ovpn-data-example"

* Initialize the `$OVPN_DATA` container that will hold the configuration files
  and certificates.  The container will prompt for a passphrase to protect the
  private key used by the newly generated certificate authority.

      docker volume create --name $OVPN_DATA
      docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm themardy/openvpn ovpn_genconfig -u udp://VPN.SERVERNAME.COM
      docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it themardy/openvpn ovpn_initpki

* Start OpenVPN server process

      docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN themardy/openvpn

* Generate a client certificate without a passphrase

      docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it themardy/openvpn easyrsa build-client-full CLIENTNAME nopass

* Retrieve the client configuration with embedded certificates

      docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm themardy/openvpn ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn

## Next Steps

### More Reading

Miscellaneous write-ups for advanced configurations are available on the
[Wiki](https://github.com/TheMardy/docker-openvpn/wiki/).

### Systemd Init Scripts

A `systemd` init script is available to manage the OpenVPN container.  It will
start the container on system boot, restart the container if it exits
unexpectedly, and pull updates from Docker Hub to keep itself up to date.

Please refer to the [Wiki](https://github.com/TheMardy/docker-openvpn/wiki/) to learn more.

## Debugging Tips

* Create an environment variable with the name DEBUG and value of 1 to enable debug output (using "docker -e").

        docker run -v $OVPN_DATA:/etc/openvpn -p 1194:1194/udp --privileged -e DEBUG=1 themardy/openvpn

* Test using a client that has openvpn installed correctly

        $ openvpn --config CLIENTNAME.ovpn

* Run through a barrage of debugging checks on the client if things don't just work

        $ ping 8.8.8.8    # checks connectivity without touching name resolution
        $ dig google.com  # won't use the search directives in resolv.conf
        $ nslookup google.com # will use search

* Consider setting up a [systemd service](https://github.com/TheMardy/docker-openvpn/wiki/Systemd-Service) for automatic
  start-up at boot time and restart in the event the OpenVPN daemon or Docker
  crashes.