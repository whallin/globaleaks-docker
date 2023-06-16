# Debian 11 (bullseye) as base image
FROM debian:11

# Copy configuration
ADD data/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD data/torrc /etc/tor/torrc

# Install dependencies
RUN apt-get update && apt-get install -y gpg curl supervisor

# Add GlobaLeaks repository
RUN echo "deb http://deb.globaleaks.org bullseye/" > /etc/apt/sources.list.d/globaleaks.list && \
    curl -sS https://deb.globaleaks.org/globaleaks.asc | apt-key add -

# Install GlobaLeaks
RUN apt-get update && apt-get install -y globaleaks && \
    apt-get clean \
    rm -rf /var/lib/apt/lists/*

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