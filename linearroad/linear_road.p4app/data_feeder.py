#!/usr/bin/env python
import sys
import argparse
from controller_rpc import RPCClient
from datasource import LRDataSource
from linear_road import *
from time import sleep

parser = argparse.ArgumentParser(description='Send stream from a file')
parser.add_argument('filename', help='Data source file', type=str)
parser.add_argument('dst', help='host:port to send messages to', type=str)
parser.add_argument('--controller', '-c', help='connect to the controller',
                        action="store_true", default=False)
args = parser.parse_args()

dst_host, dst_port = parseHostAndPort(args.dst)
producer = LRProducer(dst_host, dst_port)

if args.controller:
    toll_settings = dict(min_spd=40, min_cars=5, base_toll=1)
    cont = RPCClient()
    cont.setToll(**toll_settings)

with LRDataSource(args.filename) as ds:
    for msg in ds:
        producer.send(msg)
        #sleep(0.005)
