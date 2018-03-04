# -*- coding: utf-8 -*-

# Find the public ip v4 of a compute by parsing the value of
# `openstack server show -c addresses -f value my_vm`. The value
# should be passed in argument, as argv[1]:
# "Ext-Net=2001:41d0:302:1100::8:f101, 54.38.91.45; provider-net=192.168.0.2"

import sys
import re

# Regex for an ip v4. See, https://gist.github.com/mnordhoff/2213179
is_ipv4 = re.compile('^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')

# Split on `;` then filter to keep the string with public addresses
# (ie, `Ext-Net=...`). Then strip `Ext-Net=` from the string. Finally
# split on `,` to find all external addresses.
ext_ips = (ip for ip in sys.argv[1].split(';') if ip.startswith('Ext-Net='))\
              .next()\
              .strip('Ext-Net=')\
              .split(',')
ext_ips = map(lambda ip: ip.strip(), ext_ips) # Clean output

# Split on ',' then filter ipv4 only. Keep first.
ext_ip_v4 = next(ip for ip in ext_ips if is_ipv4.match(ip))

# Display result on stdout
print(ext_ip_v4)
