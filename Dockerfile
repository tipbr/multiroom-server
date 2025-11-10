FROM debian:bullseye-slim

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    systemd \
    lsb-release \
    procps \
    dbus \
    avahi-daemon \
    avahi-utils \
    libnss-mdns \
    && rm -rf /var/lib/apt/lists/*

# Install raspotify (which includes librespot) with the correct repository approach
RUN curl -sSL https://dtcooper.github.io/raspotify/key.asc | tee /usr/share/keyrings/raspotify-archive-keyrings.asc >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/raspotify-archive-keyrings.asc] https://dtcooper.github.io/raspotify raspotify main' | tee /etc/apt/sources.list.d/raspotify.list \
    && apt-get update \
    && apt-get install -y raspotify \
    && rm -rf /var/lib/apt/lists/*

# Install snapcast server, shairport-sync for AirPlay support, and gstreamer for Google Cast
RUN apt-get update && apt-get install -y \
    snapserver \
    shairport-sync \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-pulseaudio \
    pulseaudio \
    && rm -rf /var/lib/apt/lists/*

# Create directory for snapcast config
RUN mkdir -p /etc/snapserver

# Copy shairport-sync configuration
COPY shairport-sync.conf /etc/shairport-sync.conf

# Create snapserver config with multiple streams
RUN echo '[stream]' > /etc/snapserver/snapserver.conf \
    && echo 'source = pipe:///tmp/snapfifo-spotify?name=Spotify&sampleformat=44100:16:2&buffer=2000' >> /etc/snapserver/snapserver.conf \
    && echo 'source = pipe:///tmp/snapfifo-airplay?name=AirPlay&sampleformat=44100:16:2&buffer=2000' >> /etc/snapserver/snapserver.conf \
    && echo 'source = pipe:///tmp/snapfifo-googlecast?name=GoogleCast&sampleformat=44100:16:2&buffer=2000' >> /etc/snapserver/snapserver.conf \
    && echo '[http]' >> /etc/snapserver/snapserver.conf \
    && echo 'doc_root = /usr/share/snapserver/snapweb' >> /etc/snapserver/snapserver.conf

# Enable Avahi services for snapcast and AirPlay
COPY snapserver.service /etc/avahi/services/snapserver.service
COPY shairport-sync.service /etc/avahi/services/shairport-sync.service

# Create startup script with D-Bus, Avahi, librespot, shairport-sync, and PulseAudio for Google Cast
RUN echo '#!/bin/bash' > /start.sh \
    && echo 'set -e' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Start D-Bus daemon (required for Avahi and PulseAudio)' >> /start.sh \
    && echo 'mkdir -p /var/run/dbus' >> /start.sh \
    && echo 'rm -f /var/run/dbus/pid' >> /start.sh \
    && echo 'dbus-daemon --system --fork' >> /start.sh \
    && echo 'sleep 1' >> /start.sh \
    && echo '' >> /start.sh \
    && echo 'mkdir -p /tmp' >> /start.sh \
    && echo '# Create named pipes for audio streams' >> /start.sh \
    && echo 'mkfifo -m a=rw /tmp/snapfifo-spotify 2>/dev/null || true' >> /start.sh \
    && echo 'mkfifo -m a=rw /tmp/snapfifo-airplay 2>/dev/null || true' >> /start.sh \
    && echo 'mkfifo -m a=rw /tmp/snapfifo-googlecast 2>/dev/null || true' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Disable raspotify systemd service' >> /start.sh \
    && echo 'systemctl disable raspotify 2>/dev/null || true' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Start Avahi daemon' >> /start.sh \
    && echo 'avahi-daemon --daemonize' >> /start.sh \
    && echo 'sleep 1' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Start PulseAudio in system mode for Google Cast receiver' >> /start.sh \
    && echo 'pulseaudio --system --disallow-exit --disallow-module-loading=false --exit-idle-time=-1 &' >> /start.sh \
    && echo 'sleep 2' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Create PulseAudio sink and pipe to snapcast' >> /start.sh \
    && echo 'pactl load-module module-pipe-sink file=/tmp/snapfifo-googlecast sink_name=snapcast_googlecast format=s16le rate=44100 channels=2 || true' >> /start.sh \
    && echo 'pactl set-default-sink snapcast_googlecast || true' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Start librespot for Spotify' >> /start.sh \
    && echo 'librespot --backend pipe --device /tmp/snapfifo-spotify --name "Spotify Multiroom" &' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Start shairport-sync for AirPlay' >> /start.sh \
    && echo 'shairport-sync -c /etc/shairport-sync.conf &' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Give services time to initialize' >> /start.sh \
    && echo 'sleep 2' >> /start.sh \
    && echo '' >> /start.sh \
    && echo '# Start snapserver' >> /start.sh \
    && echo 'snapserver -c /etc/snapserver/snapserver.conf' >> /start.sh \
    && chmod +x /start.sh

# Expose the snapcast server ports
EXPOSE 1704 1705 1780
# Expose PulseAudio port for Google Cast
EXPOSE 4713
# Expose Avahi mDNS port
EXPOSE 5353/udp

# Use init system to handle processes
ENTRYPOINT ["/start.sh"]
