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
        print "Usage: send3.py"
        sys.exit(1)

    srcmac = '00:aa:bb:00:00:00'
    dstmac = '00:aa:bb:00:00:01'
    port = 80
    msg = 'hi'
    
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '100.164.100.128', dst = '43.43.40.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '100.164.100.128', dst = '43.43.40.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.123.163', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '178.31.22.70', dst = '107.28.107.71') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '144.187.28.60', dst = '1.66.27.105') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '178.31.22.70', dst = '107.28.107.71') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.33.126.83', dst = '1.96.222.205') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '221.240.197.5', dst = '5.252.32.90') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.90.2.206', dst = '1.96.223.244') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '166.139.87.73', dst = '65.50.22.225') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.151', dst = '1.103.139.4') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '10.72.121.3', dst = '1.102.49.27') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.181', dst = '1.64.216.94') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '88.152.119.231', dst = '111.205.228.206') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.61.56.89', dst = '1.96.223.155') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '107.170.178.200', dst = '43.147.200.81') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '96.111.103.68', dst = '1.107.73.178') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.181', dst = '1.64.216.94') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.138.120.88', dst = '1.96.166.250') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '123.236.179.105', dst = '3.237.87.51') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.119.217.194', dst = '1.96.222.230') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.119.217.194', dst = '1.96.222.230') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.110.10.118', dst = '1.96.166.240') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.238.4.231', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '120.178.72.26', dst = '1.96.167.113') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.41.147', dst = '1.96.166.164') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.46.167', dst = '1.47.68.166') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.98', dst = '1.47.38.193') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.46.167', dst = '1.47.68.166') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.139.68', dst = '1.96.166.250') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.46.167', dst = '1.47.68.166') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.84.70.126', dst = '1.100.159.220') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.136', dst = '43.237.96.251') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.250.18.65', dst = '1.96.167.9') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.236.126', dst = '1.96.166.250') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '131.57.76.156', dst = '153.193.46.95') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.98.136', dst = '5.240.144.4') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '106.84.38.210', dst = '1.2.210.83') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.46.167', dst = '1.47.68.166') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '199.76.207.73', dst = '5.252.32.94') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.48.205', dst = '1.96.223.185') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.41.147', dst = '1.96.166.164') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '70.142.123.53', dst = '210.108.49.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '120.186.203.249', dst = '1.96.166.204') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.136.201.127', dst = '1.96.223.181') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '167.197.111.177', dst = '1.108.198.61') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '117.94.42.4', dst = '3.249.221.65') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.98', dst = '1.47.38.193') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '152.124.151.163', dst = '5.252.121.56') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '5.62.244.96', dst = '210.108.49.161') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.84.66.210', dst = '1.37.115.176') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.41.147', dst = '1.96.166.164') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '117.82.4.57', dst = '1.153.193.158') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.98', dst = '1.47.38.193') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.98', dst = '1.47.38.193') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.106.71', dst = '1.96.223.171') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '208.39.232.165', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.19.222.95', dst = '43.239.34.29') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.238.4.231', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '106.105.195.57', dst = '1.124.228.13') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.62.172.236', dst = '57.35.22.70') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.45.108.137', dst = '1.96.222.237') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '65.125.163.1', dst = '5.252.100.69') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '39.148.52.166', dst = '210.108.26.25') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '39.148.52.166', dst = '210.108.26.25') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '199.50.151.24', dst = '3.239.255.71') / msg
    sendp(p, iface = "veth0", verbose = 0)




if __name__ == '__main__':
    main()
