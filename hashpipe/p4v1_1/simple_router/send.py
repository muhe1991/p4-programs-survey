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

mac = {'h1' : ("00:04:00:00:00:00", "00:aa:bb:00:00:00"), 'h2': ("00:04:00:00:00:01", "00:aa:bb:00:00:01")}
ip = {'h1' : '10.0.0.10', 'h2': '10.0.1.10', 'h3': '4.1.0.10', 'h4' : '89.2.1.1'}

def main():
    if len(sys.argv) != 1:
        print "Usage: send.py"
        sys.exit(1)

    src, dst = 'h1', 'h2'
    srcmac = mac[src][0]
    dstmac = mac[src][1]
    port = int(src.strip()[-1])
    count = 0
    while(count < 5):
        msg ='hello'
        
        p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = ip[src], dst = ip[dst]) / msg
        sendp(p, iface = "veth0", verbose = 1)

        p = Ether(src=srcmac, dst=dstmac, type=0x0800) / IP(src = ip['h2'], dst = ip['h4']) / msg
        sendp(p, iface = "veth0", verbose = 1)
        #print p.show()
        count += 1
        #print msg

if __name__ == '__main__':
    main()
