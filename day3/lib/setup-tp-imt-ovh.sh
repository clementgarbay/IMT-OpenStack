#!/usr/bin/env bash
set -o errexit # `help set'

SSH_KEY_SEC=~/.ssh/id_tp_omh   # SSH private key for the lab
SSH_KEY_PUB=${SSH_KEY_SEC}.pub # SSH public counter part

# Build a venv to install openstack-cli in a sandbox
if [ ! -d tp-imt-venv ]
then
   virtualenv --python=python2.7 --prompt='(tp-imt) ' tp-imt-venv
fi
. tp-imt-venv/bin/activate

# Install OpenStack CLI (if not already installed)
if ! python -c "import openstackclient" &> /dev/null
then
    pip install python-openstackclient==3.14.0
fi

# Source the openrc file provided by OVH
# Get that file from:
# Cloud > Serveurs > tp-enos-imt > OpenStack > ... > Télécharger un
# fichier de configuration OpenStack > GRA 3
. ./openrc.sh

set -o xtrace

# Import the public key of the tp into OpenStack keychain
openstack keypair show tp-omh || \
    openstack keypair create --public-key "${SSH_KEY_PUB}" tp-omh

# Setup a private network on the vRack named `provider-net'. In
# OpenStack the /provider network/ is the network setup by the admin
# to interconnect VMs. This is different to /tenant networks/ created
# by users within a tenant which are not shared among other tenants.
# In this configuration, the provider network is configured to provide
# IP on 192.168.0.0/24, started from 192.168.0.2 to 192.168.0.254. The
# `--no-dhcp' instructs netron that IP will be addressed statically.
openstack network show provider-net ||\
    openstack network create provider-net

openstack subnet show provider-net ||\
    openstack subnet create\
              --network provider-net\
              --subnet-range 192.168.0.0/24\
              --allocation-pool start=192.168.0.2,end=192.168.0.254\
              --no-dhcp\
              provider-net

# Create the `os-control-compute' machine. Put it in both public
# (i.e., `Ext-Net') and provider (i.e., `provider-net') networks.
openstack server show os-control-compute ||\
    openstack server create\
              --image 'Debian 9'\
              --flavor b2-7\
              --network Ext-Net\
              --network provider-net\
              --key-name tp-omh\
              --user-data ../../day2/lib/os-control-compute.sh\
              --wait\
              os-control-compute

# Create the `os-compute' machine. Then put it in the public network.
openstack server show os-compute ||\
    openstack server create\
              --image 'Debian 9'\
              --flavor b2-7\
              --network Ext-Net\
              --network provider-net\
              --key-name tp-omh\
              --user-data ../../day2/lib/os-compute.sh\
              --wait\
              os-compute

# Copy the private counterpart of the SSH key on `os-control-compute`
# so that it can be used to ease the SSH connection to the second
# machine.
PUBLIC_IP_OS_CONTROL_COMPUTE=$(python get-public-ip.py "$(openstack server show -c addresses -f value os-control-compute)")
scp -i "${SSH_KEY_SEC}" "${SSH_KEY_SEC}"\
    debian@${PUBLIC_IP_OS_CONTROL_COMPUTE}:/home/debian/.ssh/id_rsa

# To connect on the os-control-compute
openstack server ssh\
          --login debian\
          --identity "${SSH_KEY_SEC}"\
          --address-type Ext-Net -4\
          os-control-compute
