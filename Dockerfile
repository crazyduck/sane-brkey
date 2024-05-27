ARG MAINTAINER
FROM python:bookworm
MAINTAINER $MAINTAINER

ARG BRSCAN4_DEB=https://download.brother.com/pub/com/linux/linux/packages/brscan4-0.4.11-1.amd64.deb
ARG BRSCAN4KEY_DEB=https://download.brother.com/pub/com/linux/linux/packages/brscan-skey-0.3.2-0.amd64.deb
ARG SANEUSER
ARG SANEUSERPASS

# Install Packages 
RUN apt-get update \
&& apt-get install -y \
    sudo \
    whois \
    procps \
    \
    # sane \
    sane-utils \
    poppler-utils \
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

# get brscan4
RUN wget -O /tmp/brscan4.amd64.deb $BRSCAN4_DEB && dpkg -i /tmp/brscan4.amd64.deb

RUN wget -O /tmp/brscan-skey.amd64.deb $BRSCAN4KEY_DEB
# configure sane
RUN brsaneconfig4 -a name=dcp7065 model=DCP7065DN nodename=brodrucker && echo "192.168.10.0/24" >> /etc/sane.d/saned.conf

# Copy Sane conf
#COPY --chown=root:root init.sh /init.sh
# Copy init.sh
COPY --chown=root:root resources/init.sh /init.sh

# Expose Ports
# SANE network scanner daemon
EXPOSE 6566

#EXPOSE 5353
#EXPOSE 139

VOLUME /output
VOLUME /consume

# Default shell
CMD ["/bin/bash","/init.sh"]
