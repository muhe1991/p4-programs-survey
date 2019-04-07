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
        print "Usage: send1.py"
        sys.exit(1)

    src, dst = 'h1', 'h2'
    srcmac = '00:aa:bb:00:00:00'
    dstmac = '00:aa:bb:00:00:01'
    port = 80
    msg = 'hi'
    
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '197.89.8.178', dst = '1.146.110.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '120.104.63.110', dst = '35.240.203.254') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.235.8.155', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.192.216.115', dst = '1.145.172.183') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.192.216.115', dst = '1.145.172.183') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '13.1.149.6', dst = '1.96.164.152') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.19.164.220', dst = '208.233.254.228') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.84.240.85', dst = '3.132.119.134') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.123.163', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.184.175.251', dst = '1.96.166.240') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '15.83.232.210', dst = '153.193.117.36') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '198.88.36.241', dst = '1.124.177.87') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.250.217.75', dst = '1.96.167.85') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.248.43.197', dst = '1.96.222.150') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.23.31.176', dst = '1.96.222.138') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '57.1.234.211', dst = '1.91.225.157') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '4.36.65.12', dst = '153.193.46.38') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.148', dst = '1.110.251.196') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.164.67.137', dst = '1.65.177.183') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.250.217.75', dst = '1.96.167.85') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.201.127', dst = '1.96.223.181') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '106.84.38.143', dst = '1.15.166.226') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.77.108.248', dst = '1.8.156.9') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '208.39.232.84', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.138.181.127', dst = '1.96.223.228') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.209.201.104', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.167.199', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.98', dst = '1.45.33.80') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '13.1.149.6', dst = '1.96.164.152') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '120.186.203.249', dst = '1.96.166.204') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '28.232.205.91', dst = '1.12.170.147') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.108.151.63', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.140', dst = '107.29.168.172') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '28.97.144.68', dst = '1.96.167.70') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.226.16.152', dst = '1.96.223.181') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.138.181.127', dst = '1.96.223.228') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '198.88.36.241', dst = '1.124.177.87') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.152.38.62', dst = '1.102.64.224') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.36.125.142', dst = '1.96.167.236') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '212.251.29.29', dst = '153.193.47.117') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '67.7.29.236', dst = '102.43.173.143') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '208.39.232.61', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.98', dst = '1.45.33.80') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.209.201.192', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.144.239.0', dst = '1.96.222.219') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '66.141.179.194', dst = '210.108.60.132') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.90.2.206', dst = '1.96.223.244') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '71.195.3.209', dst = '210.108.56.251') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.238.4.231', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '173.162.174.71', dst = '102.14.133.117') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.105', dst = '1.2.54.84') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '12.236.225.10', dst = '1.96.186.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.77.108.248', dst = '1.8.156.9') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '12.236.225.10', dst = '1.96.186.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '66.81.91.169', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.104', dst = '1.150.34.79') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.159', dst = '137.183.138.50') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.6.223.116', dst = '5.240.216.86') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.111.158.189', dst = '1.96.222.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '67.233.176.179', dst = '210.108.32.99') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '197.78.57.165', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.152.38.62', dst = '1.102.64.224') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.209.201.245', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '28.70.106.198', dst = '1.96.222.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.102', dst = '1.3.251.80') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '158.255.243.46', dst = '111.205.25.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '212.226.67.33', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '144.187.28.60', dst = '1.66.27.105') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.167', dst = '1.0.227.102') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '36.137.204.196', dst = '1.148.195.80') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '201.188.208.178', dst = '1.96.231.122') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.164.211.145', dst = '3.249.2.54') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '214.65.45.201', dst = '35.240.203.247') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.23.31.176', dst = '1.96.222.138') / msg
    sendp(p, iface = "veth0", verbose = 0)


if __name__ == '__main__':
    main()
