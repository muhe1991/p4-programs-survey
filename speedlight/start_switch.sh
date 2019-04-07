#!/bin/bash

set -e 

if [ $# -lt 3 ]
    then echo "Usage: start_switch.sh variant numports maxsnapshots"
    exit
fi

echo "setting up veth interfaces"

port_config=""

for i in `seq 0 $2`;
do
    if [ ${i} == 0 ]; then
        echo "CPU port"
    else
        echo "Port" ${i}
    fi

    port1=$(( ${i} * 2 ))
    port2=$(( ${i} * 2 + 1 ))

    port_config="${port_config} -i ${i}@veth${port1}"

    sudo ip link delete veth${port1} >& /dev/null || true
    sudo ip link delete veth${port2} >& /dev/null || true
    sudo ip link add veth${port1} type veth peer name veth${port2}
    sudo sysctl -q net.ipv6.conf.veth${port1}.disable_ipv6=1
    sudo sysctl -q net.ipv6.conf.veth${port2}.disable_ipv6=1
    sudo ifconfig veth${port1} up promisc
    sudo ifconfig veth${port2} up promisc
done

mkdir -p out

# write the config files
python p4src/utilities/generate_p4vars.py out $2 $3

# generate rule install commands
python p4src/utilities/generate_rules.py $1 $2 $3

# compile the switch
p4c-bmv2 --json out/$1.json p4src/$1.p4 --primitives p4src/primitives/primitives.json

# start simple_switch running the P4 code. port 0 = CPU port
sudo ./third_party/behavioral-model/targets/speedlight_switch/simple_switch ${port_config} out/$1.json
