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

source $THIS_DIR/../env.sh

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

if [ $# -lt 1 ]; then
    echo "Please specify register index"
    exit 1
fi
index=$1

i=0

while [ $i -lt 32 ]
do
#echo $i
echo "register_read flow_tracker_stage1 $i" | $CLI_PATH simple_router.json
#echo ','
echo "register_read packet_counter_stage1 $i" | $CLI_PATH simple_router.json
#echo ',,'
echo "register_read flow_tracker_stage2 $i" | $CLI_PATH simple_router.json
#echo ','
echo "register_read packet_counter_stage2 $i" | $CLI_PATH simple_router.json
#echo ",,"
# echo "\n"
i=$[$i+1]
done



