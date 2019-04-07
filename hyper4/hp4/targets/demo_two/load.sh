#!/bin/bash

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/../../../env.sh

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

$CLI_PATH ../../hp4.json 22222 < ./A.txt
$CLI_PATH ../../hp4.json 22222 < ./B_1.txt
$CLI_PATH ../../hp4.json 22222 < ./B_2.txt
$CLI_PATH ../../hp4.json 22222 < ./setup_vn.txt
