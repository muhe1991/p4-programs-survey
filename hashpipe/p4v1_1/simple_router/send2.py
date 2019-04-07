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
        print "Usage: send2.py"
        sys.exit(1)

    srcmac = '00:aa:bb:00:00:00'
    dstmac = '00:aa:bb:00:00:01'
    port = 80
    msg = 'hi'
    
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '142.54.3.18', dst = '35.240.203.247') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.119.163.206', dst = '1.102.89.68') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '205.38.229.41', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '6.172.207.28', dst = '208.89.117.253') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.173', dst = '1.0.3.222') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '148.92.117.249', dst = '1.102.127.50') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '113.169.241.172', dst = '1.96.222.132') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '30.187.70.176', dst = '1.96.166.240') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '129.201.147.168', dst = '43.239.238.254') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '15.83.232.209', dst = '153.193.117.43') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '117.91.221.69', dst = '1.96.228.67') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.65.110.243', dst = '1.96.222.237') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '122.138.7.7', dst = '3.151.114.131') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '197.78.57.215', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.137.47.98', dst = '1.96.223.52') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.209.201.217', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '205.38.229.188', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.157.173.33', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '39.183.184.70', dst = '1.96.167.9') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '173.162.174.71', dst = '102.14.133.117') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.102', dst = '1.34.248.21') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '102.1.84.90', dst = '43.206.171.27') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.25.115.194', dst = '1.96.167.56') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.229.0.142', dst = '5.252.90.214') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.29.115.116', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.37.250.218', dst = '3.248.234.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.137.52.25', dst = '1.96.166.173') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '102.6.32.157', dst = '221.46.220.102') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '102.6.32.157', dst = '221.46.220.102') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '100.159.187.56', dst = '208.89.121.171') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '183.190.174.107', dst = '1.150.209.83') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '111.209.150.229', dst = '210.108.56.240') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '109.147.8.232', dst = '1.2.38.184') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.37.184.30', dst = '1.96.223.239') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '116.209.201.171', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '102.0.115.0', dst = '111.205.228.129') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '205.38.229.94', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '197.78.57.35', dst = '66.216.25.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.111.179.170', dst = '1.96.223.36') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '184.21.123.130', dst = '211.106.242.60') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '117.92.23.134', dst = '1.45.68.235') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '112.111.179.170', dst = '1.96.223.36') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '194.253.242.112', dst = '153.193.46.216') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.123', dst = '1.81.56.123') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '13.1.149.6', dst = '1.96.164.152') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.37.184.30', dst = '1.96.223.239') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.102', dst = '1.13.5.138') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.10.57.179', dst = '43.233.106.124') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '204.103.13.219', dst = '221.46.221.163') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '128.61.59.69', dst = '1.96.223.133') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.139.101.170', dst = '1.0.227.102') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '113.181.185.162', dst = '1.39.174.181') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '73.149.65.226', dst = '210.108.49.161') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '43.255.233.20', dst = '221.46.220.203') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.238.4.231', dst = '1.96.167.6') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.77.108.26', dst = '1.146.59.107') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '153.193.150.99', dst = '221.46.220.227') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '207.157.173.33', dst = '1.96.167.17') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '119.236.185.197', dst = '1.96.223.248') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '130.77.108.26', dst = '1.146.59.107') / msg
    sendp(p, iface = "veth0", verbose = 0)
    p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = '74.90.63.201', dst = '210.108.56.240') / msg
    sendp(p, iface = "veth0", verbose = 0)



if __name__ == '__main__':
    main()
