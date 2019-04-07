#!/bin/bash

set -e
sudo apt-get update

echo "Cloning submodules"
git submodule update --init --recursive

# Originally built against (included): https://github.com/p4lang/behavioral-model/commit/66cefc5e901eafcebb0e1a8f681a05795463215a
echo "Installing BMv2..."
cd third_party/behavioral-model
./install_deps.sh
./autogen.sh
./configure
make -j
sudo make install
cd -

# Originally built against (included): https://github.com/p4lang/p4c-bm/commit/d75624e18f4ae79e9e5cb478c33d221711f76574
echo "Installing p4c-bm..."
cd third_party/p4c-bm
sudo pip install -r requirements.txt
sudo python setup.py install
cd -

# copy switch to behavioral-model directory, build.
echo "copying ./p4src/primitives/primitives.cpp --> third_party/behavioral-model/targets/speedlight_switch/primitives.cpp"
cp -raf third_party/behavioral-model/targets/simple_switch/. third_party/behavioral-model/targets/speedlight_switch
cat p4src/primitives/primitives.append >> third_party/behavioral-model/targets/speedlight_switch/primitives.cpp

echo "building third_party/behavioral-model/targets/speedlight_switch"
cd third_party/behavioral-model/targets/speedlight_switch
make
cd -

echo "compiling snapshot_init/startsnap.cpp"
mkdir -p out
g++ -std=c++11 snapshot_init/startsnap.cpp -o out/startsnap
pip install dpkt

sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_default=16777216
sudo sysctl -w net.core.rmem_default=16777216
