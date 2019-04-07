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
from mininet.link import TCLink

from p4_mininet import P4Switch, P4Host

import argparse
from time import sleep
import os
import subprocess

_THIS_DIR = os.path.dirname(os.path.realpath(__file__))
_THRIFT_BASE_PORT = 22222

parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action="store", required=True)
parser.add_argument('--jsons', help='Paths to JSON config files',
                    type=str, nargs='*', action="store", required=True)
parser.add_argument('--cli', help='Path to BM CLI',
                    type=str, action="store", required=True)
parser.add_argument('--commands', help='Paths to initial CLI commands',
                    type=str, nargs='*', action="store", default=["commands.txt"])
parser.add_argument('--topo', help='Path to scenario topology file',
                    type=str, action="store", default="topo.txt")
parser.add_argument('--hmacs', help='Host MAC addresses',
                    type=str, nargs='*', action="store", default=[])
parser.add_argument('--pcap', help='Turns on pcap generation',
                    action="store_true")
# Useful if we need to use runtime_CLI instead of sswitch_CLI:
#parser.add_argument('--p4factory', help='Use p4factory intead of standalone repos',
#                    action="store_true")

args = parser.parse_args()

class MyTopo(Topo):
    def __init__(self, sw_path, json_paths, nb_hosts, nb_switches, links, **opts):
        # Initialize topology and default options
        Topo.__init__(self, **opts)

        jpath = json_paths[0]

        for i in xrange(nb_switches):
            if len(json_paths) > i:
              jpath = json_paths[i]
            switch = self.addSwitch('s%d' % (i + 1),
                                    sw_path = sw_path,
                                    json_path = jpath,
                                    thrift_port = _THRIFT_BASE_PORT + i,
                                    pcap_dump = args.pcap,
                                    device_id = i)
        
        for h in xrange(nb_hosts):
            macstr = '00:04:00:00:00:%02x' %h
            if(len(args.hmacs) > h):
              macstr = args.hmacs[h]
            host = self.addHost('h%d' % (h + 1),
                                ip = '10.0.0.%d/24' % (h + 1),
                                mac = macstr)

        for a, b in links:
            self.addLink(a, b)

def read_topo():
    nb_hosts = 0
    nb_switches = 0
    links = []
    with open(args.topo, "r") as f:
        line = f.readline()[:-1]
        w, nb_switches = line.split()
        assert(w == "switches")
        line = f.readline()[:-1]
        w, nb_hosts = line.split()
        assert(w == "hosts")
        for line in f:
            if not f: break
            a, b = line.split()
            links.append( (a, b) )
    return int(nb_hosts), int(nb_switches), links
            

def main():
    nb_hosts, nb_switches, links = read_topo()

    topo = MyTopo(args.behavioral_exe,
                  args.jsons,
                  nb_hosts, nb_switches, links)

    net = Mininet(topo = topo,
                  host = P4Host,
                  switch = P4Switch,
                  controller = None )
    net.start()

    for n in xrange(nb_hosts):
        h = net.get('h%d' % (n + 1))
        for off in ["rx", "tx", "sg"]:
            cmd = "/sbin/ethtool --offload eth0 %s off" % off
            print cmd
            h.cmd(cmd)
        print "disable ipv6"
        h.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv4.tcp_congestion_control=reno")
        h.cmd("iptables -I OUTPUT -p icmp --icmp-type destination-unreachable -j DROP")

    sleep(1)

    jsons = args.jsons
    commands = args.commands

    sw_json = jsons[0]
    sw_commands = commands[0]

    for i in xrange(nb_switches):
        # Useful if we need to use runtime_CLI instead of sswitch_CLI:
        #if args.p4factory:
        #  cmd = [args.cli, "--json", args.json,
        #         "--thrift-port", str(_THRIFT_BASE_PORT + i)]
        #else:
        if len(jsons) > i:
          sw_json = jsons[i]
        if len(commands) > i:
          sw_commands = commands[i]

        cmd = [args.cli, sw_json,
               str(_THRIFT_BASE_PORT + i)]

        with open(sw_commands, "r") as f:
            print " ".join(cmd)
            try:
                output = subprocess.check_output(cmd, stdin = f)
                print output
            except subprocess.CalledProcessError as e:
                print e
                print e.output
        s = net.get('s%d' % (i + 1))
        cmd = "ifconfig | grep -o -E \'s%d\-eth.\'" % (i + 1)
        ifaces = (s.cmd(cmd)).split()
        for iface in ifaces:
          print("Disconnecting %s" % iface)
          s.cmd("nmcli dev disconnect iface %s" % iface)

    sleep(1)

    print "Ready !"

    CLI( net )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    main()
