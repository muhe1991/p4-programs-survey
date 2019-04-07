This is the p4 prototype of the Hashpipe Algorithm. `read_register.sh` allows you to read specific sets of locations. 
`send.py`is a script to send a specific set of packets with a given 5-tuple. This has been written to directly parallel one of the CAIDA traces to cross-verify

`commands.txt` helps populate the tables with corresponding actions. The code to do the routing itself is in `simple_router/p4src/`. More instructions can be found in `simple_router/`
