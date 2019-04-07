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

HP4_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $HP4_DIR/../env.sh
# note that the above command changes $THIS_DIR to the directory of env.sh

PROJ=${PWD##*/}

P4C_BM_SCRIPT=$P4C_BM_PATH/p4c_bm/__main__.py

SWITCH_PATH=$BMV2_PATH/targets/simple_switch/simple_switch

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

$P4C_BM_SCRIPT p4src/$PROJ.p4 --json $PROJ.json
sudo PYTHONPATH=$PYTHONPATH:$BMV2_PATH/mininet/ \
    python $THIS_DIR/mininet/topo_mix.py \
    --behavioral-exe $BMV2_PATH/targets/simple_switch/simple_switch \
    --jsons $PROJ.json $PROJ.json $PROJ.json \
    --cli $CLI_PATH \
    --commands $HP4_DIR/targets/demo_one/start_s1_s2_s3.txt \
      $HP4_DIR/targets/demo_one/start_s1_s2_s3.txt \
      $HP4_DIR/targets/demo_one/start_s1_s2_s3.txt \
    --topo $HP4_DIR/targets/demo_one/topo.txt
