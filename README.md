Changes as per use-case:

1. Change Dockerfile last line CMD ["--dhcp-range=172.18.0.50,172.18.0.99,255.255.255.0,24h"] to the network you want to provide DHCP for.

2. Change pxelinux.cfg/default

TIMEOUT 20
PROMPT 1
DEFAULT pxeboot
LABEL pxeboot
    KERNEL /coreos/coreos-live-kernel
    APPEND ip=dhcp rd.neednet=1 initrd=/coreos/coreos-live-initramfs.img console=tty0 console=ttyS0 coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=http://172.18.0.1:8000/config.ign
IPAPPEND 2

to reflect install device and ignition config file.

3. Change etc/dnsmasq.conf 

interface=enp3s0.20
To reflect the interface to provide DHCP and pxefile.

dhcp-option=3,172.18.0.1
To reflect gateway for the hosts.



