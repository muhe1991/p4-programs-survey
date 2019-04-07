#!/bin/bash

sudo mn -c
sudo killall simple_switch
redis-cli FLUSHALL
