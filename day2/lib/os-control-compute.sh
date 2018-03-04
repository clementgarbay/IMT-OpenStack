#!/usr/bin/env bash
set -x
set -e

# Update apt and install requirements/useful packages
apt-get update
apt-get install -y \
        htop jq lynx tmux vim \
        git libffi-dev libssl-dev python-dev build-essential \
        python-pip python-setuptools\
        bridge-utils tcpdump

# Download EnOS and install it from source
git clone https://github.com/rcherrueau/enos.git -b tp-imt --depth 1 /home/debian
pip install -e file:///home/debian/enos#egg=enos

# Dowload the tarball and extract it to the home directory
wget -qO- http://enos.irisa.fr/tp-imt/tp2.tar.gz  | tar -xzv -C /home/debian

# Statically give ens4 an IP (192.168.0.2)
sed -i '11s/allow-hotplug ens4/auto ens4/' /etc/network/interfaces
sed -i '12s/iface ens4 inet dhcp/iface ens4 inet static/' /etc/network/interfaces
echo '  address 192.168.0.2/24' >> /etc/network/interfaces
# ifdown --ignore-errors ens4 && ifup --ignore-errors ens4

echo "[ -r /home/debian/current/admin-openrc ] && . /home/debian/current/admin-openrc" >> /home/debian/.bashrc

systemctl reboot
