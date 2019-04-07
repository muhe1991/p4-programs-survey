#!/bin/bash

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/../../../env.sh

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

#$CLI_PATH ../../hp4.json 22222 < ./C_s1.txt
$CLI_PATH ../../hp4.json 22223 < ./swap_to_C.txt
#$CLI_PATH ../../hp4.json 22224 < ./C_s3.txt
