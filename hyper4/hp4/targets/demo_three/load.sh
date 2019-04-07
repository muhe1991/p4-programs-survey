#!/bin/bash

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/../../../env.sh

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

$CLI_PATH ../../hp4.json 22222 < ./r1.txt
$CLI_PATH ../../hp4.json 22222 < ./r2.txt
$CLI_PATH ../../hp4.json 22222 < ./r3.txt
$CLI_PATH ../../hp4.json 22222 < ./r4.txt
$CLI_PATH ../../hp4.json 22222 < ./f1.txt
$CLI_PATH ../../hp4.json 22222 < ./f2.txt
$CLI_PATH ../../hp4.json 22222 < ./l2_s1.txt
$CLI_PATH ../../hp4.json 22222 < ./l2_s2.txt
$CLI_PATH ../../hp4.json 22222 < ./setup_vn.txt
