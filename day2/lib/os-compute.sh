#!/usr/bin/env bash
set -x
set -e

# Update apt and install requirements / useful packages
apt-get update
apt-get install -y \
        htop jq vim lynx \
        python-pip python-dev

# Statically give ens4 an IP (192.168.0.3)
sed -i '11s/allow-hotplug ens4/auto ens4/' /etc/network/interfaces
sed -i '12s/iface ens4 inet dhcp/iface ens4 inet static/' /etc/network/interfaces
echo '  address 192.168.0.3/24' >> /etc/network/interfaces
# echo '  gateway 192.168.0.2' >> /etc/network/interfaces
# ifdown --ignore-errors ens4 && ifup --ignore-errors ens4


systemctl reboot
