mc_nat_P4
=====================

Multicast replication with Network Address Translation (NAT) in P4

This means that for every one packet that comes in that matches
an IP DST, the switch can output a cascade of packets with
different IP DSTs to various switch output ports.

Tables:
set_mcg - sets the multicast output group of input packets based on IP DST

nat_table - sets the IP DST of the different multicast nodes

Files:
commands_mc_nat.txt: CLI commands to set up a simple set of multicast
replication with NAT.  It first sets default drops for set_mcg and nat_table,
then sets up entries in those tables.  It creates 3 new multicast
nodes ("1","2","3"), and then associates them with multicast group "1".

Tested on bmv2 with target simple_switch


