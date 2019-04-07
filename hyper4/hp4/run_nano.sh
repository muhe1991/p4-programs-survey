#!/bin/bash

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

NANO_PATH=$THIS_DIR/../tools/nanomsg_client.py

PROJ=${PWD##*/}

SW=0
QUIETOPT=

if [ $# -eq 1 ]
  then
    SW=$(($1-1))
fi

if [ $# -eq 2 ]
  then
    if [[ $2 == q ]];
      then
        QUIETOPT=--quiet
    fi
fi

sudo $NANO_PATH --json $PROJ.json --socket ipc:///tmp/bm-$SW-log.ipc $QUIETOPT
