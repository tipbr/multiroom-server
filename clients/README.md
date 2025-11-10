# Raspberry Pi Zero + DAC+ Zero Client Setup

This guide is specifically for setting up Raspberry Pi Zero W with DAC+ Zero (pHAT DAC) as Snapcast clients.

## Hardware

- Raspberry Pi Zero W
- DAC+ Zero (pHAT DAC)
- MicroSD card (8GB+)
- Power supply

## Installation

### 1. Install Raspbian Lite

Flash Raspbian Lite to your SD card and boot the Pi Zero.

### 2. Configure DAC+ Zero

The DAC+ Zero needs to be enabled in the boot configuration.

Edit `/boot/config.txt`:
```bash
sudo nano /boot/config.txt
```

Add this line:
```
dtoverlay=hifiberry-dac
```

Comment out the default audio:
```
#dtparam=audio=on
```

Save and reboot:
```bash
sudo reboot
```

### 3. Verify DAC Detection

After reboot, check if the DAC is detected:
```bash
aplay -l
```

You should see:
```
card 0: sndrpihifiberry [sndrpihifiberry]
```

### 4. Install Snapclient

```bash
sudo apt-get update
sudo apt-get install -y snapclient
```

### 5. Configure Snapclient

Edit the snapclient configuration:
```bash
sudo nano /etc/default/snapclient
```

Set the server IP and audio device (replace `<SERVER_IP>` with your Raspberry Pi 4's IP):
```
SNAPCLIENT_OPTS="--host <SERVER_IP> --soundcard hw:CARD=sndrpihifiberry"
```

### 6. Enable and Start

```bash
sudo systemctl enable snapclient
sudo systemctl start snapclient
```

## Verification

### Check Service Status
```bash
sudo systemctl status snapclient
```

### View Logs
```bash
sudo journalctl -u snapclient -f
```

### Test Audio
```bash
speaker-test -c 2 -t wav -D hw:CARD=sndrpihifiberry
```

You should hear white noise from both channels.

## Troubleshooting

### No Audio Output

1. Verify DAC is recognized:
   ```bash
   aplay -l
   ```

2. Check volume levels:
   ```bash
   alsamixer
   ```

3. Test the DAC directly:
   ```bash
   speaker-test -c 2 -t wav -D hw:CARD=sndrpihifiberry
   ```

### Connection Issues

1. Verify server is reachable:
   ```bash
   ping <SERVER_IP>
   ```

2. Check snapclient logs:
   ```bash
   sudo journalctl -u snapclient -f
   ```

3. Verify correct server IP in config:
   ```bash
   cat /etc/default/snapclient
   ```

### Audio Stuttering on WiFi

If experiencing dropouts over WiFi, increase the latency buffer:

```bash
sudo nano /etc/default/snapclient
```

Change to:
```
SNAPCLIENT_OPTS="--host <SERVER_IP> --soundcard hw:CARD=sndrpihifiberry --latency 200"
```

Restart:
```bash
sudo systemctl restart snapclient
```

### WiFi Stability

Disable WiFi power saving for better stability:
```bash
sudo iw wlan0 set power_save off
```

To make permanent, add to `/etc/rc.local` before `exit 0`:
```bash
sudo nano /etc/rc.local
```

Add:
```
/sbin/iw wlan0 set power_save off
```

## Multiple Clients

Repeat this setup for each room. Each Pi Zero will appear in the Snapcast web interface where you can:
- Rename clients (e.g., "Living Room", "Kitchen")
- Group clients for synchronized playback
- Adjust individual volumes
- Apply delay compensation for acoustic alignment

## Volume Control

Control volume through:
- Snapcast web interface: `http://<SERVER_IP>:1780`
- Command line: `alsamixer`
- Physical volume controls on your amplifier/speakers
