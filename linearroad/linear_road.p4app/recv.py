#!/usr/bin/env python
import sys
import signal
import argparse
from linear_road import *

parser = argparse.ArgumentParser(description='Receive (and forward) a stream of LR messages')
parser.add_argument('--forward', '-f', help='host:port to forward messages to', type=str, default=None)
parser.add_argument('--port', '-p', help='Listen port', type=int, default=1234)
args = parser.parse_args()

consumer = LRConsumer(args.port)

producer = None
if args.forward is not None:
    dst_host, dst_port = parseHostAndPort(args.forward)
    producer = LRProducer(dst_host, dst_port)

def handleMsg(msg):
    print msg
    if isinstance(msg, PosReport): return
    if isinstance(msg, AccntBalReq): return
    if producer: producer.send(msg)

def signalHandler(signal, frame):
    while consumer.hasNewMsg():
        handleMsg(consumer.recv())
    consumer.close()
    if producer:
        producer.close()
    sys.exit(0)

signal.signal(signal.SIGINT, signalHandler)

while True:
    handleMsg(consumer.recv())
