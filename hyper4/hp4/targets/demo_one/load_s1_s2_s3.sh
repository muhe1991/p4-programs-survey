#!/bin/bash

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/../../../env.sh

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

$CLI_PATH ../../hp4.json 22222 < ./A_s1.txt
$CLI_PATH ../../hp4.json 22223 < ./A_s2.txt
$CLI_PATH ../../hp4.json 22224 < ./A_s3.txt
$CLI_PATH ../../hp4.json 22222 < ./B_s1.txt
$CLI_PATH ../../hp4.json 22223 < ./B_s2.txt
$CLI_PATH ../../hp4.json 22224 < ./B_s3.txt
$CLI_PATH ../../hp4.json 22222 < ./C_s1.txt
$CLI_PATH ../../hp4.json 22223 < ./C_s2_1.txt
$CLI_PATH ../../hp4.json 22223 < ./C_s2_2.txt
$CLI_PATH ../../hp4.json 22223 < ./C_s2_3.txt
$CLI_PATH ../../hp4.json 22224 < ./C_s3.txt
$CLI_PATH ../../hp4.json 22223 < ./setup_vn_s2.txt
