#!/usr/bin/env python

from scapy.all import *
import sys
import argparse
import zlib

msgtype = {
    1 : 'PREPARE',
    2 : 'PROMISE',
    3 : 'ACCEPT',
    4 : 'ACCEPTED',
    5 : 'DELIVER',
}

class Paxos(Packet): 
   name = "Paxos" 
   fields_desc =  [ 
                    IntField("inst", 0),
                    ShortField("proposal", 0), 
                    ShortField("vproposal", 0), 
                    ShortField("acceptor", 0), 
                    ShortEnumField("msgtype", 3, msgtype), 
                    XIntField("val", 0),
                    XIntField("fsh", 0),
                    XIntField("fsl", 0),
                    XIntField("feh", 0),
                    XIntField("fel", 0),
                    XIntField("csh", 0),
                    XIntField("csl", 0),
                    XIntField("ceh", 0),
                    XIntField("cel", 0),
                    XIntField("ash", 0),
                    XIntField("asl", 0),
                    XIntField("aeh", 0),
                    XIntField("ael", 0),
                    ]

bind_layers(UDP, Paxos, dport=0x8888)

def generate(args):
    p = Ether(src="00:00:00:00:00:01", dst="00:00:00:00:00:02") / \
        IP(src="10.0.0.1", dst="10.0.0.2") / \
        UDP(sport=54213)

    p = p / Paxos(inst=args.inst, proposal=args.proposal, acceptor=args.acceptor, msgtype=args.msgtype, val=args.value)

    # hexdump(p)
    p.show()

    sendp(p, iface = args.interface, count=args.count)

def handle(x):
    hexdump(x)
    x.show()

def receive(args):
    sniff(iface = args.interface, filter="udp and dst port 0x8888", prn = lambda x: handle(x))

def main():
    parser = argparse.ArgumentParser(description='Paxos packet generator')
    parser.add_argument("-i", "--interface", default='vf0', help="bind to specified interface")
    parser.add_argument("-v", "--value", type=int, default=0x1234, help="set value")
    parser.add_argument("--inst", type=int, default=1, help="set the instance")
    parser.add_argument('-t', "--msgtype", type=int, default=3, help="set the message type")
    parser.add_argument('-p', "--proposal", type=int, default=0, help="set the proposal value")
    parser.add_argument('-a', "--acceptor", type=int, default=0, help="set acceptor's id")
    parser.add_argument('-s', "--server", default=False, action='store_true', help="set role")
    parser.add_argument('-c', "--count", type=int, default=1, help="set the number of packets for transmitting")

    args = parser.parse_args()

    if args.server:
        receive(args)
    else:
        generate(args)

if __name__=='__main__':
    main()