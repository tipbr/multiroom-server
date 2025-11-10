# Raspberry Pi Zero + DAC+ Zero Quick Setup

## What You Need

- Raspberry Pi Zero W with DAC+ Zero (pHAT DAC) attached
- Raspbian Lite installed
- Your Raspberry Pi 4 server IP address

## Quick Setup Steps

### 1. Enable the DAC+ Zero

```bash
sudo nano /boot/config.txt
```

Add:
```
dtoverlay=hifiberry-dac
```

Comment out:
```
#dtparam=audio=on
```

Save (Ctrl+X, Y, Enter) and reboot:
```bash
sudo reboot
```

### 2. Install and Configure Snapclient

After reboot:
```bash
sudo apt-get update
sudo apt-get install -y snapclient
sudo nano /etc/default/snapclient
```

Add this line (replace `192.168.1.10` with your Pi 4's IP):
```
SNAPCLIENT_OPTS="--host 192.168.1.10 --soundcard hw:CARD=sndrpihifiberry"
```

Save and start:
```bash
sudo systemctl enable snapclient
sudo systemctl start snapclient
```

### 3. Verify

Check if it's running:
```bash
sudo systemctl status snapclient
```

Test audio:
```bash
speaker-test -c 2 -t wav -D hw:CARD=sndrpihifiberry
```

You should hear test tones. If yes, you're done! The client will appear in your web interface at `http://<pi4-ip>:1780`

## Common Issues

**No audio?**
```bash
# Check if DAC is detected
aplay -l
# Should show: card 0: sndrpihifiberry

# Check volume
alsamixer
```

**Can't connect to server?**
```bash
# Verify server is reachable
ping 192.168.1.10

# Check the logs
sudo journalctl -u snapclient -f
```

**WiFi stuttering?**
```bash
sudo nano /etc/default/snapclient
# Change to:
SNAPCLIENT_OPTS="--host 192.168.1.10 --soundcard hw:CARD=sndrpihifiberry --latency 200"

sudo systemctl restart snapclient
```

That's it! Repeat for each room.
