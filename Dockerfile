ARG MAINTAINER
FROM debian:stable-slim
MAINTAINER $MAINTAINER

ENV DEBIAN_FRONTEND noninteractive

ARG BRSCAN4_DEB=https://download.brother.com/pub/com/linux/linux/packages/brscan4-0.4.11-1.amd64.deb
ARG BRSCAN4KEY_DEB=https://download.brother.com/pub/com/linux/linux/packages/brscan-skey-0.3.2-0.amd64.deb

# Install Packages 
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && locale-gen en_US en_US.UTF-8 \
    && dpkg-reconfigure locales

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        # sudo \
        # whois \
        # poppler-utils \
        procps \
        sane \
        sane-utils \
        dbus \
        avahi-utils \
        runit \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

    
# get brscan4
ADD $BRSCAN4_DEB \
    $BRSCAN4KEY_DEB \
    /tmp/
    
RUN dpkg -i /tmp/brscan4*.amd64.deb
    
RUN adduser saned scanner \
    && adduser saned lp \
    && chown saned:lp /etc/sane.d/saned.conf /etc/sane.d/dll.conf

# configure sane
RUN brsaneconfig4 -a name=dcp7065 model=DCP7065DN nodename=brodrucker && echo "192.168.10.0/24" >> /etc/sane.d/saned.conf

# Copy Sane conf
#COPY --chown=root:root init.sh /init.sh
# Copy init.sh
# COPY --chown=root:root resources/init.sh /init.sh


# VOLUME /output
# VOLUME /consume

COPY services/ /etc/sv/
COPY runit_startup.sh /

RUN ln -s /etc/sv/dbus /etc/service/ \
    && ln -s /etc/sv/saned /etc/service/

# Expose Ports
EXPOSE 6566 10000 10001

CMD ["/runit_startup.sh"]
