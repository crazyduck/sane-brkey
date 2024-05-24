ARG MAINTAINER
FROM debian:stable-slim
MAINTAINER $MAINTAINER

ARG SANEUSER
ARG SANEUSERPASS

# Install Packages (basic tools, cups, basic drivers, HP drivers)
RUN apt-get update \
&& apt-get install -y \
    sudo \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo \
  --create-home \
  --home-dir=/home/$SANEUSER \
  --shell=/bin/bash \
  --password=$(mkpasswd $SANEUSERPASS) \
  $SANEUSER \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

# Copy Sane conf
#COPY --chown=root:root init.sh /init.sh
# Copy init.sh
COPY --chown=root:root resources/init.sh /init.sh

# Expose Ports
# SANE network scanner daemon
EXPOSE 6566

#EXPOSE 5353
#EXPOSE 139

# Default shell
CMD ["/bin/bash","/init.sh"]