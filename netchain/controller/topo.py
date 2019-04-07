import os, logging, sys, subprocess, argparse, time

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI
from mininet.node import CPULimitedHost
from mininet.link import TCLink

from p4_mininet import P4Switch, P4Host
from nc_config import *
from exe_cmd import *


###########################################
## get parameters
###########################################
class MyTopo(Topo):
    def __init__(self, sw_path, json_path, switches, thrift_base_port, 
        pcap_dump_flag, log_dir, hosts, links, **opts):
        Topo.__init__(self, **opts)

        for i in xrange(switches):
            self.addSwitch("s%d" % (i+1),
                sw_path = sw_path,
                json_path = json_path,
                thrift_port = thrift_base_port+i,
                pcap_dump = pcap_dump_flag,
                device_id = i,
                verbose = True,
                log_dir = log_dir)

        for i in xrange(hosts):
            self.addHost("h%d" % (i+1))

        for a,b in links:
            self.addLink(a, b)

def read_topo(topology_file):
    nb_hosts = 0
    nb_switches = 0
    links = []
    with open(topology_file, "r") as f:
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
    return int(nb_switches), int(nb_hosts), links

def config_mininet(parameters):
    switches, hosts, links = read_topo(parameters.topology_file)
    topo = MyTopo("%s/targets/simple_switch/simple_switch" % parameters.bmv2,
        parameters.switch_json,
        switches,
        parameters.thrift_base_port,
        False,
        parameters.project_dir + '/logs/switches',
        hosts,
        links)

    net = Mininet(topo = topo,
        host = P4Host,
        switch = P4Switch,
        controller = None,
        autoStaticArp=True )

    net.start()

    for n in range(hosts):
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
        h.setIP("10.0.0.%d" % (n + 1))
        h.setMAC("aa:bb:cc:dd:ee:0%d" % (n + 1))
        for i in range(hosts):
            if (i != n):
                h.setARP("10.0.0.%d" % (i + 1), "aa:bb:cc:dd:ee:0%d" % (i + 1))
    net.get('s1').setMAC("aa:bb:cc:dd:ee:11","s1-eth1")
    net.get('s1').setMAC("aa:bb:cc:dd:ee:12","s1-eth2")

    net.get('s2').setMAC("aa:bb:cc:dd:ee:21","s2-eth1")
    net.get('s2').setMAC("aa:bb:cc:dd:ee:22","s2-eth2")
    net.get('s2').setMAC("aa:bb:cc:dd:ee:23","s2-eth3")

    net.get('s3').setMAC("aa:bb:cc:dd:ee:31","s3-eth1")
    net.get('s3').setMAC("aa:bb:cc:dd:ee:32","s3-eth2")

    net.get('s4').setMAC("aa:bb:cc:dd:ee:41","s4-eth1")
    net.get('s4').setMAC("aa:bb:cc:dd:ee:42","s4-eth2")
    net.get('s4').setMAC("aa:bb:cc:dd:ee:43","s4-eth3")
    net.get('s4').setMAC("aa:bb:cc:dd:ee:44","s4-eth4")
    net.get('s4').setMAC("aa:bb:cc:dd:ee:45","s4-eth5")
    
    time.sleep(1)
    commands_list = ["config/commands.txt", "config/commands_1.txt", "config/commands_2.txt", "config/commands_3.txt"]
    file_index = 0
    for i in range(switches):
        cmd = [parameters.runtime_CLI, parameters.switch_json, str(parameters.thrift_base_port + i)]
        with open(commands_list[file_index], "r") as f:
            file_index = file_index + 1
            print " ".join(cmd)
            try:
                output = subprocess.check_output(cmd, stdin = f)
                print output
            except subprocess.CalledProcessError as e:
                print e
                print e.output

    time.sleep(1)

    logging.info("Ready !")

    return (switches, hosts, net)
