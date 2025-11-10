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

# Install snapcast server and shairport-sync for AirPlay support
RUN apt-get update && apt-get install -y \
    snapserver \
    shairport-sync \
    && rm -rf /var/lib/apt/lists/*

# Create directory for snapcast config
RUN mkdir -p /etc/snapserver

# Copy shairport-sync configuration
COPY shairport-sync.conf /etc/shairport-sync.conf

# Create snapserver config with multiple streams
RUN echo '[stream]' > /etc/snapserver/snapserver.conf \
    && echo 'source = pipe:///tmp/snapfifo-spotify?name=Spotify&sampleformat=44100:16:2&buffer=2000' >> /etc/snapserver/snapserver.conf \
    && echo 'source = pipe:///tmp/snapfifo-airplay?name=AirPlay&sampleformat=44100:16:2&buffer=2000' >> /etc/snapserver/snapserver.conf \
    && echo '[http]' >> /etc/snapserver/snapserver.conf \
    && echo 'doc_root = /usr/share/snapserver/snapweb' >> /etc/snapserver/snapserver.conf

# Enable Avahi services for snapcast and AirPlay
COPY snapserver.service /etc/avahi/services/snapserver.service
COPY shairport-sync.service /etc/avahi/services/shairport-sync.service

# Create startup script with Avahi, librespot, and shairport-sync
RUN echo '#!/bin/bash' > /start.sh \
    && echo 'mkdir -p /tmp' >> /start.sh \
    && echo '# Create named pipes for audio streams' >> /start.sh \
    && echo 'mkfifo -m a=rw /tmp/snapfifo-spotify' >> /start.sh \
    && echo 'mkfifo -m a=rw /tmp/snapfifo-airplay' >> /start.sh \
    && echo 'systemctl disable raspotify' >> /start.sh \
    && echo '# Start Avahi daemon' >> /start.sh \
    && echo 'avahi-daemon --daemonize' >> /start.sh \
    && echo '# Start librespot for Spotify' >> /start.sh \
    && echo 'librespot --backend pipe --device /tmp/snapfifo-spotify --name "Spotify Multiroom" &' >> /start.sh \
    && echo '# Start shairport-sync for AirPlay' >> /start.sh \
    && echo 'shairport-sync -c /etc/shairport-sync.conf &' >> /start.sh \
    && echo '# Give services time to initialize' >> /start.sh \
    && echo 'sleep 2' >> /start.sh \
    && echo '# Start snapserver' >> /start.sh \
    && echo 'snapserver -c /etc/snapserver/snapserver.conf' >> /start.sh \
    && chmod +x /start.sh

# Expose the snapcast server ports
EXPOSE 1704 1705 1780
# Expose Avahi mDNS port
EXPOSE 5353/udp

# Use init system to handle processes
ENTRYPOINT ["/start.sh"]
