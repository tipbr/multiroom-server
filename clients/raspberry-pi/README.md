# Raspberry Pi Snapclient Setup Guide

## Prerequisites

- Raspberry Pi (any model with audio output)
- Raspberry Pi OS (formerly Raspbian) installed
- Network connection to the multiroom server

## Installation

1. Update your system:
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

2. Install snapclient:
```bash
sudo apt-get install -y snapclient
```

## Configuration

1. Copy the example configuration:
```bash
sudo cp snapclient.conf /etc/default/snapclient
```

2. Edit the configuration to point to your server:
```bash
sudo nano /etc/default/snapclient
```

Update the `SNAPCLIENT_OPTS` line with your server's IP address:
```
SNAPCLIENT_OPTS="--host YOUR_SERVER_IP"
```

3. Enable and start the service:
```bash
sudo systemctl enable snapclient
sudo systemctl start snapclient
```

## Audio Output Configuration

### Headphone Jack (3.5mm)

Force audio to the headphone jack:
```bash
sudo raspi-config
# Select: System Options -> Audio -> Headphones
```

Or set it directly:
```bash
amixer cset numid=3 1
```

### HDMI Audio

Force audio to HDMI:
```bash
amixer cset numid=3 2
```

### USB Audio Device

If using a USB DAC or sound card:

1. List available devices:
```bash
aplay -L
```

2. Update snapclient configuration:
```bash
sudo nano /etc/default/snapclient
```

Add the device parameter:
```
SNAPCLIENT_OPTS="--host YOUR_SERVER_IP --soundcard hw:CARD=Device,DEV=0"
```

Replace `Device` with your USB device name from `aplay -L`.

## Troubleshooting

### Check Service Status

```bash
sudo systemctl status snapclient
```

### View Logs

```bash
sudo journalctl -u snapclient -f
```

### Test Audio Output

```bash
speaker-test -c 2 -t wav
```

### Adjust Volume

Via command line:
```bash
alsamixer
```

Or through the Snapcast web interface at `http://SERVER_IP:1780`

## Autostart on Boot

The snapclient service is automatically configured to start on boot. To disable:
```bash
sudo systemctl disable snapclient
```

To re-enable:
```bash
sudo systemctl enable snapclient
```

## Performance Tips

1. **Reduce Latency**: If on a good wired connection, try lower latency:
   ```
   SNAPCLIENT_OPTS="--host YOUR_SERVER_IP --latency 100"
   ```

2. **Increase Buffer**: If experiencing dropouts on WiFi:
   ```
   SNAPCLIENT_OPTS="--host YOUR_SERVER_IP --latency 300"
   ```

3. **WiFi Power Management**: Disable WiFi power saving for better stability:
   ```bash
   sudo iw wlan0 set power_save off
   ```

   To make permanent, add to `/etc/rc.local`:
   ```bash
   /sbin/iw wlan0 set power_save off
   ```
