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
        print "Usage: send4.py"
        sys.exit(1)

    srcmac = '00:aa:bb:00:00:00'
    dstmac = '00:aa:bb:00:00:01'
    port = 80
    msg = 'hi'
    
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '210.22.15.110', dst = '221.46.221.122') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '39.148.52.166', dst = '210.108.26.25') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '114.21.79.71', dst = '3.249.237.54') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.62.172.236', dst = '57.35.22.70') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '109.227.1.188', dst = '1.107.142.114') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '221.153.195.133', dst = '168.147.86.51') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '65.223.24.163', dst = '111.204.79.70') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '216.17.212.104', dst = '216.17.217.61') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '212.85.85.175', dst = '1.124.87.130') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.170.54.183', dst = '1.96.167.9') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.164.219.239', dst = '1.124.40.249') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '183.224.161.162', dst = '5.243.0.246') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '205.38.229.205', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '28.67.127.118', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.129', dst = '1.1.34.171') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '223.101.124.225', dst = '74.238.224.86') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '100.164.100.128', dst = '43.43.40.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '140.249.85.183', dst = '111.205.228.234') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '120.104.63.110', dst = '35.240.203.254') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '206.216.186.12', dst = '137.183.237.32') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '208.39.232.121', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '203.156.61.55', dst = '1.102.220.51') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '65.223.24.163', dst = '111.204.79.70') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '65.223.24.163', dst = '111.204.79.70') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '79.242.207.41', dst = '153.193.46.83') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.137.255.243', dst = '1.96.228.238') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.227.23.139', dst = '1.96.166.164') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.137.255.243', dst = '1.96.228.238') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '69.193.124.226', dst = '153.193.46.187') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.10.177.179', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.65.160.25', dst = '1.96.222.155') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '109.147.8.111', dst = '1.2.38.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.238.4.231', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.227.23.139', dst = '1.96.166.164') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.98.139', dst = '1.15.166.226') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '151.20.32.237', dst = '36.49.132.218') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.167.171.142', dst = '1.96.223.210') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.239.84', dst = '146.39.162.103') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.33.121.196', dst = '1.96.223.146') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '132.156.215.206', dst = '111.205.213.177') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.239.84', dst = '146.39.162.103') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.238.4.231', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.122', dst = '1.46.101.123') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '102.141.124.80', dst = '210.108.56.243') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '36.140.99.3', dst = '5.243.62.57') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '28.67.127.118', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.152.38.62', dst = '1.102.64.224') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.164.132.74', dst = '1.152.164.182') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.122', dst = '1.46.101.123') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '123.201.237.33', dst = '5.243.0.62') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.209.201.27', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.118', dst = '137.182.249.45') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.122', dst = '1.46.101.123') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '99.158.44.122', dst = '1.46.101.123') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '137.161.223.243', dst = '153.193.46.217') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '208.39.232.42', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '167.197.111.177', dst = '1.108.198.61') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '102.0.115.0', dst = '111.205.228.129') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.8.178.13', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '108.10.246.205', dst = '1.96.223.171') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '126.124.191.231', dst = '153.193.46.111') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '104.209.92.60', dst = '111.37.201.173') / msg
    sendp(p, iface = "veth0", verbose = 0)

if __name__ == '__main__':
    main()
