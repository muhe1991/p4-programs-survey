#!/bin/sh

prefix='run'
dash='-'
ext='.pcap'
switch='s1'
iface1='eth1'
iface2='eth2'

tcpdump -w $prefix$1$dash$iface1$ext -c 20 -i $switch$dash$iface1 "ether[0:2] == 0x0000 and ether[1:1] == 0x00" &
tcpdump -w $prefix$1$dash$iface2$ext -c 20 -i $switch$dash$iface2 "ether[0:2] == 0x0000 and ether[1:1] == 0x00" &
