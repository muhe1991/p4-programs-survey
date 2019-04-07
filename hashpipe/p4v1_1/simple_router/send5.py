#!/usr/bin/python

# Copyright 2013-present Barefoot Networks, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from scapy.all import sniff, sendp
from scapy.all import Packet
from scapy.all import ShortField, IntField, LongField, BitField
from scapy.all import Ether, IP, TCP
import networkx as nx

import sys

def main():
    if len(sys.argv) != 1:
        print "Usage: send5.py"
        sys.exit(1)

    srcmac = '00:aa:bb:00:00:00'
    dstmac = '00:aa:bb:00:00:01'
    port = 80
    msg = 'hi'
    
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '205.38.229.230', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.119.182.32', dst = '1.102.100.56') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '197.78.57.178', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '109.225.203.112', dst = '3.248.156.73') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.84.69.158', dst = '1.34.151.28') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.228.217.83', dst = '1.96.222.150') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '181.183.122.237', dst = '74.238.204.108') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.154', dst = '1.38.59.94') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.228.217.83', dst = '1.96.222.150') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '131.57.76.156', dst = '153.193.46.95') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.119.190.33', dst = '1.96.223.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '181.183.122.237', dst = '74.238.204.108') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.135', dst = '1.103.139.4') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '13.1.149.6', dst = '1.96.164.152') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.184.175.251', dst = '1.96.166.240') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.8.16.84', dst = '1.96.167.92') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '28.67.127.118', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '131.204.248.226', dst = '35.240.203.196') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '131.57.76.156', dst = '153.193.46.95') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '144.187.28.60', dst = '1.66.27.105') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '117.91.221.69', dst = '1.96.228.67') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.78.68', dst = '1.102.89.68') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '67.216.134.53', dst = '213.203.225.60') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.99', dst = '1.0.67.66') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.61.56.89', dst = '1.96.223.155') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '127.54.208.195', dst = '221.46.221.124') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.123.163', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.25.175.14', dst = '1.96.167.92') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.77.108.7', dst = '145.103.141.135') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.77.108.7', dst = '145.103.141.135') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.108.124.177', dst = '1.144.12.13') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '109.87.11.100', dst = '1.65.181.172') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '39.198.15.118', dst = '3.254.16.73') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '181.183.122.237', dst = '74.238.204.108') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '196.135.73.233', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.126', dst = '1.158.17.123') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '205.99.120.234', dst = '145.103.120.99') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.138.181.127', dst = '1.96.223.228') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.108.124.177', dst = '1.144.12.13') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.61.56.89', dst = '1.96.223.155') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.119.245', dst = '1.96.167.9') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '121.129.221.24', dst = '43.239.203.91') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.108.137', dst = '1.96.222.237') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.45.240', dst = '1.96.166.250') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.131.188.142', dst = '1.96.222.150') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.64.177', dst = '73.240.167.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.250.216.198', dst = '1.96.166.223') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.115', dst = '1.101.127.52') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '199.130.180.67', dst = '12.63.53.16') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.131.184.181', dst = '1.96.166.230') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.131.188.142', dst = '1.96.222.150') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.250.216.198', dst = '1.96.166.223') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.131.188.142', dst = '1.96.222.150') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '109.229.135.120', dst = '137.182.8.31') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '39.242.255.94', dst = '5.252.42.107') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.250.216.198', dst = '1.96.166.223') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '1.96.91.57', dst = '111.205.228.195') / msg
    sendp(p, iface = "veth0", verbose = 0)


if __name__ == '__main__':
    main()
