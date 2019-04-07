#!/bin/bash

set -e 

if [ -z $1 ]; then
    echo "Usage: ./start_listener.sh variant"
    exit 1
fi

# install rules
./third_party/behavioral-model/targets/speedlight_switch/sswitch_CLI --thrift-port 9090 < out/commands.txt

# start listener
sudo python snapshot_init/snapListener.py $1

