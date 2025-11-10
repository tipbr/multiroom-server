#!/bin/bash
# Raspberry Pi Zero + DAC+ Zero automated setup script
# Run this on each Pi Zero W with DAC+ Zero attached

set -e

echo "========================================"
echo "Pi Zero + DAC+ Zero Client Setup"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Ask for server IP
read -p "Enter your Raspberry Pi 4 server IP address: " SERVER_IP

# Validate IP format (basic check)
if [[ ! $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Invalid IP address format."
    exit 1
fi

echo ""
echo "Step 1: Configuring DAC+ Zero..."

# Check if already configured
if grep -q "dtoverlay=hifiberry-dac" /boot/config.txt; then
    echo "DAC+ Zero already configured in /boot/config.txt"
else
    echo "dtoverlay=hifiberry-dac" >> /boot/config.txt
    echo "DAC+ Zero configuration added"
fi

# Disable onboard audio if not already disabled
if grep -q "^dtparam=audio=on" /boot/config.txt; then
    sed -i 's/^dtparam=audio=on/#dtparam=audio=on/' /boot/config.txt
    echo "Onboard audio disabled"
fi

echo ""
echo "Step 2: Installing snapclient..."
apt-get update
apt-get install -y snapclient

echo ""
echo "Step 3: Configuring snapclient..."
cat > /etc/default/snapclient << EOF
# Snapclient configuration for Pi Zero + DAC+ Zero
SNAPCLIENT_OPTS="--host $SERVER_IP --soundcard hw:CARD=sndrpihifiberry"
EOF

echo ""
echo "Step 4: Enabling snapclient service..."
systemctl enable snapclient

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "IMPORTANT: You must reboot for the DAC+ Zero to be recognized."
echo ""
echo "After reboot, the client will automatically start and connect"
echo "to the server at $SERVER_IP"
echo ""
echo "To verify after reboot:"
echo "  sudo systemctl status snapclient"
echo "  aplay -l    # Should show 'sndrpihifiberry'"
echo ""
read -p "Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Please reboot manually: sudo reboot"
fi
