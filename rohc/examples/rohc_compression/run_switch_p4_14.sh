#!/bin/bash

# Copyright 2013-present Barefoot Networks, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/../../env.sh

P4C_EXE_PATH=$P4C_PATH/build/p4c

SWITCH_PATH=$BMV2_PATH/targets/simple_switch/simple_switch

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

# Probably not very elegant but it works nice here: we enable interactive mode
# to be able to use fg. We start the switch in the background, sleep for 2
# minutes to give it time to start, then add the entries and put the switch
# process back in the foreground
set -m
$P4C_EXE_PATH -x p4-14 -b bmv2-v1model-p4org p4src/rohc_compression_p4_14.p4 -o program.bmv2.json -v
if [ $? -ne 0 ]; then
echo "p4 compilation failed"
exit 1
fi

# This gets root permissions, and gives libtool the opportunity to "warm-up"
sudo $SWITCH_PATH >/dev/null 2>&1
sudo $SWITCH_PATH program.bmv2.json/rohc_compression_p4_14.json \
    -i 0@veth0 -i 1@veth2 -i 2@veth4 -i 3@veth6 -i 4@veth8 \
    --nanolog ipc:///tmp/bm-0-log.ipc --log-console \
    --pcap &
#sudo $SWITCH_PATH program.bmv2.json/rohc_compression_p4_14.json \
#    -i 0@veth0 -i 1@veth2 -i 2@veth4 -i 3@veth6 -i 4@veth8 \
#    --nanolog ipc:///tmp/bm-0-log.ipc \
#    --pcap &
sleep 2
echo "**************************************"
echo "Sending commands to switch through CLI"
echo "**************************************"
$CLI_PATH program.bmv2.json/rohc_compression_p4_14.json < commands.txt
echo "READY!!!"
fg
