# Multiroom Audio Server

A Docker-based multiroom audio server supporting multiple streaming protocols including Spotify (via librespot) and AirPlay (via shairport-sync), synchronized across multiple clients using Snapcast.

## Features

- 🎵 **Spotify Support** - Stream Spotify to your multiroom setup using librespot
- 🍎 **AirPlay Support** - Cast from any Apple device using AirPlay (via shairport-sync)
- 🔊 **Synchronized Playback** - Perfect audio synchronization across multiple rooms using Snapcast
- 🌐 **mDNS Discovery** - Automatic device discovery on your network
- 🐳 **Docker Support** - Easy deployment with Docker and Docker Compose
- 🎛️ **Web Interface** - Control your multiroom setup via the Snapcast web interface

## Quick Start

### Prerequisites

- Docker
- Docker Compose

### Deployment

1. Clone this repository:
```bash
git clone https://github.com/tipbr/multiroom-server.git
cd multiroom-server
```

2. Start the server:
```bash
docker-compose up -d
```

3. Access the Snapcast web interface at `http://localhost:1780`

## Docker Compose Configuration

```yaml
services:
  librespot-snapcast:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: librespot-snapcast
    network_mode: host # Use host networking for better audio performance and mDNS discovery
    restart: unless-stopped
    volumes:
      - /var/run/dbus:/var/run/dbus # Share D-Bus with host for Avahi
      - /var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket # Share Avahi socket with host
    environment:
      - TZ=UTC # Set your timezone
    privileged: true # Required for some system-level operations
    ports:
      - "1704:1704" # Snapcast server port
      - "1705:1705" # Snapcast control port
      - "1780:1780" # Snapcast HTTP server port
      - "5353:5353/udp" # Avahi mDNS port
```

## Configuration

### Server Configuration

The server configuration is managed in `snapserver.conf`. It defines:
- Bind address and port
- Log level
- Audio stream sources (Spotify and AirPlay pipes)

### Client Configuration

Client configuration examples are provided in the `clients/` directory. See the [Client Setup Guide](clients/README.md) for detailed instructions on setting up Snapcast clients.

## Architecture

The system consists of three main components:

1. **Snapcast Server** - The core synchronization server that manages audio streams
2. **Audio Sources**:
   - **librespot** - Spotify client that outputs to a named pipe
   - **shairport-sync** - AirPlay receiver that outputs to a named pipe
3. **Snapcast Clients** - Devices that receive and play synchronized audio

## Usage

### Spotify

1. Open Spotify on any device
2. Look for "Spotify Multiroom" in the available devices
3. Select it and start playing music

### AirPlay

1. Open any audio app on your iOS/macOS device
2. Look for "AirPlay Multiroom" in AirPlay devices
3. Select it and start streaming

### Web Interface

Access the Snapcast web interface at `http://<server-ip>:1780` to:
- View connected clients
- Adjust volume levels
- Manage audio streams
- Group/ungroup clients

## Ports

- **1704** - Snapcast server port (TCP)
- **1705** - Snapcast control port (TCP)
- **1780** - Snapcast HTTP server / Web interface
- **5353** - Avahi mDNS (UDP)

## Troubleshooting

### mDNS/Avahi Issues

If devices are not being discovered on your network:
1. Ensure the container is running with `network_mode: host`
2. Check that Avahi daemon is running inside the container
3. Verify that port 5353/UDP is not blocked by your firewall

### Audio Quality Issues

If you experience audio quality problems:
1. Adjust the buffer size in `snapserver.conf`
2. Check network latency between server and clients
3. Ensure sufficient network bandwidth

### Spotify Not Appearing

If "Spotify Multiroom" doesn't appear in Spotify:
1. Verify the container is running: `docker ps`
2. Check container logs: `docker logs librespot-snapcast`
3. Ensure librespot is running inside the container

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project uses the following open-source components:
- [Snapcast](https://github.com/badaix/snapcast) - Synchronous multiroom audio player
- [librespot](https://github.com/librespot-org/librespot) - Open source Spotify client
- [shairport-sync](https://github.com/mikebrady/shairport-sync) - AirPlay audio receiver

## Acknowledgments

Built with open-source components to create a powerful, flexible multiroom audio system.
