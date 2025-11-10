# Snapcast Client Configuration

This directory contains configuration examples for setting up Snapcast clients to connect to your multiroom audio server.

## Client Setup

Snapcast clients can run on various platforms including:
- Raspberry Pi
- Linux desktop/laptop
- Android devices
- Windows
- macOS

## Installation

### Debian/Ubuntu/Raspberry Pi OS

```bash
# Install snapclient
sudo apt-get update
sudo apt-get install snapclient

# Start the service
sudo systemctl enable snapclient
sudo systemctl start snapclient
```

### Configuration

Edit the snapclient configuration to point to your server:

```bash
sudo nano /etc/default/snapclient
```

Set the server IP address:
```
SNAPCLIENT_OPTS="--host <server-ip>"
```

Restart the service:
```bash
sudo systemctl restart snapclient
```

## Example Configurations

### Raspberry Pi Configuration

See [raspberry-pi/snapclient.conf](raspberry-pi/snapclient.conf) for a complete Raspberry Pi setup.

**Key settings:**
- Audio output device configuration
- Buffer settings for optimal latency
- Volume normalization

### Linux Desktop Configuration

See [linux-desktop/snapclient.conf](linux-desktop/snapclient.conf) for desktop Linux setup.

**Key settings:**
- PulseAudio integration
- ALSA device configuration
- Sample format settings

### Docker Client Configuration

See [docker/docker-compose.yml](docker/docker-compose.yml) for running a client in Docker.

**Use case:** Running a client in a container alongside other services.

## Advanced Configuration

### Latency Tuning

Adjust the buffer size to optimize for your network:

```bash
# Lower latency (LAN)
snapclient --host <server-ip> --latency 100

# Higher latency (WiFi or congested network)
snapclient --host <server-ip> --latency 300
```

### Audio Device Selection

List available audio devices:
```bash
snapclient --list
```

Specify a particular device:
```bash
snapclient --host <server-ip> --soundcard <device-id>
```

### Volume Control

Set initial volume:
```bash
snapclient --host <server-ip> --volume 75
```

## Troubleshooting

### Client Not Connecting

1. Verify server is reachable:
   ```bash
   telnet <server-ip> 1704
   ```

2. Check firewall settings on both server and client

3. Review client logs:
   ```bash
   sudo journalctl -u snapclient -f
   ```

### Audio Stuttering

1. Increase buffer/latency:
   ```bash
   snapclient --host <server-ip> --latency 200
   ```

2. Check network quality:
   ```bash
   ping <server-ip>
   ```

3. Monitor CPU usage on client device

### No Audio Output

1. Verify correct audio device is selected:
   ```bash
   snapclient --list
   ```

2. Check volume levels (both snapclient and system)

3. Test audio device with other applications:
   ```bash
   speaker-test -c 2
   ```

## Multiple Clients

You can run multiple clients on the same network, each representing a different room or zone. The Snapcast web interface allows you to:
- Group/ungroup clients for synchronized playback
- Adjust individual volume levels
- Mute specific rooms
- Set delay compensation for acoustic alignment

## Client Scripts

The `scripts/` subdirectory contains helper scripts for:
- Automatic client installation
- Configuration generation
- Service management

See individual script files for usage instructions.
