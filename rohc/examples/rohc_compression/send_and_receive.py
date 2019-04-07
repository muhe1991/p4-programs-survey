from scapy.all import *
import sys
import gc
import datetime
import threading
from threading import Lock
from struct import *

RTP_PAYLOAD = 'hello, Python world!'
mutex = Lock()
gc.disable()

class Receiver(threading.Thread):
    def __init__(self, **kwargs):
        threading.Thread.__init__(self)
        self.it = 0
        self.end = False
        self.pkt_num = kwargs['pkt_num']

    def received(self, p):
        mutex.acquire()
        self.file_log_rx.write(str(p) + "\n")
        self.it += 1
        if self.it%1000 == 0:
            print "Received Packet #%d on port 3" % self.it
            print(datetime.datetime.now())
        mutex.release()
        if self.it >= self.pkt_num:
            print "Received #%d packets. Finishing" % self.it
            self.file_log_rx.close()
            self.end = True
            sys.exit(0)

    def run(self):
        self.file_log_rx = open("log_rx", "w")
        while True:
            sniff(iface="veth7", prn=lambda x: self.received(x))

    def running(self):
        return self.end

def main():
    if len(sys.argv) == 1:
        print "Total number of packet not defined. Using the input file size"
        print "Use python send_and_receive.py <pkt_num> for generating a known number of packets"
        it_total = 1000000
    elif len(sys.argv) == 2:
        it_total = int(sys.argv[1])
        print "Generating #%d packets" % it_total
    else:
        print "Invalid parameters"
        print "Use python send_and_receive.py <pkt_num> for generating a known number of packets"

    i = 0
    file_in = open("compressed_pkts", "r")
    file_log_tx = open("log_tx", "w")
    Receiver(pkt_num=it_total).start()

    for line in file_in:
        if i < it_total:
            mutex.acquire()
            p = Ether(dst="ff:ff:ff:ff:ff:ff", src="aa:aa:aa:aa:aa:aa",type=0xdd00)/line[:-1].decode("hex")
            i = i + 1
            if i%1000 == 0:
                print "Sending Packet #%d on port 0, listening on port 3" % i
                print(datetime.datetime.now())
            file_log_tx.write(str(p) + "\n")
            sendp(p, iface="veth1", verbose=0)
            mutex.release()
            time.sleep(0.002)
        else:
            break

    file_in.close()
    file_log_tx.close()

if __name__ == '__main__':
    main()
