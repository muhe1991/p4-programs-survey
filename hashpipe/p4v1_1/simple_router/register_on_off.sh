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
    echo "Please specify 'on' or 'off' as argument"
    exit 1
fi
if [ $1 = "on" ]; then
    echo "Enabling packet drop count"
    v=1
elif [ $1 = "off" ]; then
    echo "Disabling packet drop count"
    v=0
else
    echo "Invalid argument, must be one of 'on' or 'off'"
    exit 1
fi

echo "register_write drops_register_enabled 0 $v" | $CLI_PATH simple_router.json

echo "Checking value..."
echo "register_read drops_register_enabled 0" | $CLI_PATH simple_router.json
