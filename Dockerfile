# Debian 11 (bullseye) as base image
FROM debian:11

# Install dependencies
RUN apt-get update && \
    apt-get install -y gpg curl supervisor

# Add GlobaLeaks repository
RUN echo "deb http://deb.globaleaks.org bullseye/" > /etc/apt/sources.list.d/globaleaks.list && \
    curl -sS https://deb.globaleaks.org/globaleaks.asc | tee /etc/apt/trusted.gpg.d/globaleaks.asc

# Install GlobaLeaks
RUN apt-get update && \
    apt-get install -y globaleaks && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configs
ADD data/torrc /etc/tor/torrc
ADD data/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Tor configuration
ENV TORPIDDIR=/var/run/tor
ENV TORLOGDIR=/var/log/tor
RUN mkdir -m 02755 "$TORPIDDIR" && chown debian-tor:debian-tor "$TORPIDDIR"
RUN chmod 02750 "$TORLOGDIR" && chown debian-tor:adm "$TORLOGDIR"

# Expose ports
EXPOSE 80
EXPOSE 443
# Docker volume for persistent data
VOLUME [ "/var/globaleaks/" ]

# Run supervisord
CMD ["/usr/bin/supervisord"]