#!/usr/bin/python

from scapy.all import sniff, sendp
from scapy.all import Packet
from scapy.all import LongField

import sys

NUM_PACKETS = 20

class HyPer4Test(Packet):
    name = "HyPer4Test"
    fields_desc = [
        LongField("preamble", 0)
    ]

def main():
    i = 0;
    msg = "beep"
    while(i < NUM_PACKETS):
        #msg = raw_input("What do you want to send: ")

        p = HyPer4Test() / msg
        print p.show()
        sendp(p, iface = "eth0")
        i += 1
        # print msg

if __name__ == '__main__':
    main()
