FROM alpine:3.11.5

LABEL maintainer "ferrari.marco@gmail.com"

# Install the necessary packages
RUN apk add --update \
  dnsmasq \
  wget \
  && rm -rf /var/cache/apk/*

ENV SYSLINUX_VERSION 6.03
ENV TEMP_SYSLINUX_PATH /tmp/syslinux-"$SYSLINUX_VERSION"

ENV COREOS_VERSION 32.20200715.3.0
ENV TEMP_COREOS_PATH /tmp/coreos-"$COREOS_VERSION"


WORKDIR /tmp

RUN \
  mkdir -p "$TEMP_SYSLINUX_PATH" \
  && wget -q https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-"$SYSLINUX_VERSION".tar.gz \
  && tar -xzf syslinux-"$SYSLINUX_VERSION".tar.gz \
  && mkdir -p /var/lib/tftpboot \
  && cp "$TEMP_SYSLINUX_PATH"/bios/core/pxelinux.0 /var/lib/tftpboot/ \
  && cp "$TEMP_SYSLINUX_PATH"/bios/com32/libutil/libutil.c32 /var/lib/tftpboot/ \
  && cp "$TEMP_SYSLINUX_PATH"/bios/com32/elflink/ldlinux/ldlinux.c32 /var/lib/tftpboot/ \
  && cp "$TEMP_SYSLINUX_PATH"/bios/com32/menu/menu.c32 /var/lib/tftpboot/ \
  && rm -rf "$TEMP_SYSLINUX_PATH" \
  && rm /tmp/syslinux-"$SYSLINUX_VERSION".tar.gz 

RUN \
  mkdir -p /var/lib/tftpboot/coreos \
  && wget -q -O  /var/lib/tftpboot/coreos/coreos-live-kernel https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/"$COREOS_VERSION"/x86_64/fedora-coreos-"$COREOS_VERSION"-live-kernel-x86_64 \ 
  && wget -q -O  /var/lib/tftpboot/coreos/coreos-live-initramfs.img https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/"$COREOS_VERSION"/x86_64/fedora-coreos-"$COREOS_VERSION"-live-initramfs.x86_64.img 

# Configure DNSMASQ
COPY etc/ /etc

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=172.18.0.50,172.18.0.99,255.255.255.0,24h"]
