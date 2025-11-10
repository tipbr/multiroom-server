# Multiroom Audio Server

Raspberry Pi 4-based multiroom audio server supporting Spotify, AirPlay, and Google Cast, synchronized across Raspberry Pi Zero clients with DAC+ Zero using Snapcast.

## Hardware Requirements

### Server
- Raspberry Pi 4 (any RAM variant)
- MicroSD card (16GB+)
- Power supply
- Ethernet connection (recommended)

### Clients (per room)
- Raspberry Pi Zero W
- DAC+ Zero (pHAT DAC)
- MicroSD card (8GB+)
- Power supply

## Software Requirements

- Raspbian Lite on all devices
- Docker and Docker Compose on the server

## Server Setup (Raspberry Pi 4)

### 1. Install Raspbian Lite

Flash Raspbian Lite to your Pi 4's SD card and boot it up.

### 2. Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker pi
sudo apt-get install -y docker-compose
```

Log out and back in for group changes to take effect.

### 3. Install the Multiroom Server

```bash
git clone https://github.com/tipbr/multiroom-server.git
cd multiroom-server
docker-compose up -d
```

The server will start and be accessible at `http://<pi4-ip>:1780`

## Client Setup (Raspberry Pi Zero + DAC+ Zero)

### 1. Install Raspbian Lite

Flash Raspbian Lite to your Pi Zero's SD card.

### 2. Configure DAC+ Zero

Edit `/boot/config.txt`:
```bash
sudo nano /boot/config.txt
```

Add this line:
```
dtoverlay=hifiberry-dac
```

Comment out or remove:
```
#dtparam=audio=on
```

Reboot:
```bash
sudo reboot
```

### 3. Install Snapclient

```bash
sudo apt-get update
sudo apt-get install -y snapclient
```

### 4. Configure Snapclient

Edit the configuration:
```bash
sudo nano /etc/default/snapclient
```

Replace `<SERVER_IP>` with your Pi 4's IP address:
```
SNAPCLIENT_OPTS="--host <SERVER_IP> --soundcard hw:CARD=sndrpihifiberry"
```

### 5. Start Snapclient

```bash
sudo systemctl enable snapclient
sudo systemctl start snapclient
```

Repeat steps 1-5 for each room/client.

## Usage

### Spotify

1. Open Spotify on your phone/computer
2. Look for "Spotify Multiroom" in available devices
3. Select it and start playing

### AirPlay

1. Open Control Center on iOS or use AirPlay menu on macOS
2. Select "AirPlay Multiroom"
3. Start playing audio

### Google Cast

1. Open any Cast-enabled app
2. Tap the Cast icon
3. Select the multiroom server
4. Start casting

### Web Control

Access `http://<pi4-ip>:1780` to:
- View all connected clients
- Adjust individual room volumes
- Group/ungroup rooms
- Switch between audio sources

## Troubleshooting

### Server Issues

**Container not starting:**
```bash
docker logs librespot-snapcast
```

**Rebuild after changes:**
```bash
docker-compose down
docker-compose up -d --build
```

### Client Issues

**No audio from DAC+ Zero:**
```bash
# Verify DAC is recognized
aplay -l

# Should show: card 0: sndrpihifiberry

# Test audio
speaker-test -c 2 -t wav -D hw:CARD=sndrpihifiberry
```

**Client not connecting:**
```bash
# Check if server is reachable
ping <SERVER_IP>

# Check snapclient status
sudo systemctl status snapclient

# View logs
sudo journalctl -u snapclient -f
```

**Audio stuttering on WiFi:**
```bash
# Increase latency buffer
sudo nano /etc/default/snapclient
# Change to:
SNAPCLIENT_OPTS="--host <SERVER_IP> --soundcard hw:CARD=sndrpihifiberry --latency 200"

sudo systemctl restart snapclient
```

## Network Configuration

All devices must be on the same network. For best performance:
- Use ethernet for the server (Pi 4)
- WiFi is acceptable for clients (Pi Zero W)
- Ensure router has good WiFi coverage
- Reserve IP addresses for all devices in your router

## Advanced Configuration

### Adjusting Audio Quality

Edit `snapserver.conf` to change encoder settings:
```bash
nano snapserver.conf
```

### Multiple Rooms

Repeat the client setup for each room. Each client will appear in the web interface where you can:
- Name each room
- Create groups for synchronized playback
- Adjust individual volumes
- Apply delay compensation if needed

## Technical Details

### Ports Used
- 1704: Snapcast server
- 1705: Snapcast control
- 1780: Web interface
- 4713: PulseAudio (Google Cast)
- 5353: mDNS/Avahi

### Audio Pipeline
```
Spotify/AirPlay/Cast → Named Pipes → Snapserver → Network → Snapclients → DAC+ Zero → Speakers
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

This project uses:
- [Snapcast](https://github.com/badaix/snapcast) - Synchronous multiroom audio
- [librespot](https://github.com/librespot-org/librespot) - Spotify client
- [shairport-sync](https://github.com/mikebrady/shairport-sync) - AirPlay receiver
- [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/) - Google Cast receiver
