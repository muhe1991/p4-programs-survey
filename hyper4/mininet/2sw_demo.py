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

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI

from p4_mininet import P4Switch, P4Host

import argparse
from time import sleep

parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action="store", required=True)
parser.add_argument('--thrift-port1', help='Thrift server port for table updates',
                    type=int, action="store", default=22222)
parser.add_argument('--thrift-port2', help='Thrift server port for table updates',
                    type=int, action="store", default=33333)

args = parser.parse_args()


class SingleSwitchTopo(Topo):
    "Single switch connected to n (< 256) hosts."
    def __init__(self, sw_path, thrift_port1, thrift_port2, **opts):
        # Initialize topology and default options
        Topo.__init__(self, **opts)

        sw1 = self.addSwitch('s1',
                             sw_path = sw_path,
                             thrift_port = thrift_port1,
                             pcap_dump = True)
        sw2 = self.addSwitch('s2',
                             sw_path = sw_path,
                             thrift_port = thrift_port2,
                             pcap_dump = True)

        h1 = self.addHost('h1',
                          ip = "10.0.0.2/24",
                          mac = '11:12:13:14:15:01')
        self.addLink(h1, sw1)

        h2 = self.addHost('h2',
                          ip = "10.0.0.3/24",
                          mac = '21:22:23:24:25:02')
        self.addLink(h2, sw2)

        self.addLink(sw1, sw2)

def main():

    topo = SingleSwitchTopo(args.behavioral_exe,
                            args.thrift_port1,
                            args.thrift_port2
    )
    net = Mininet(topo = topo,
                  host = P4Host,
                  switch = P4Switch,
                  controller = None )
    net.start()

    h1 = net.get('h1')
    h1.describe()
    h2 = net.get('h2')
    h2.describe()

    sleep(1)

    print "Ready !"

    CLI( net )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'output' )
    main()
