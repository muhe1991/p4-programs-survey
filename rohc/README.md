# p4-programs

How to build?

- `cd ..`
- `git clone https://github.com/engjefersonsantiago/behavioral-model.git bmv2`
- `git clone https://github.com/engjefersonsantiago/p4c-bm.git p4c-bmv2`
- `git clone --recursive https://github.com/engjefersonsantiago/p4c.git p4c -b fixed_externs_may2017`
- `git clone https://github.com/engjefersonsantiago/rohc.git ROHC`
- `cd ROHC`
- `./autogen.sh`
- `make && sudo make install`
- `cd ../bmv2`
- `./autogen.sh`
- `./configure`
- `make && sudo make install`
- `cd ../p4c`
- `./bootstrap.sh`
- `cd build`
- `make -j4 && sudo make install`
- `cd ../../p4c-bmv2`
- `sudo pip install -r requirements_v1_1.txt`
- `cd ../examples/<target_program>`
- `sudo ../veth_setup.sh`
- `sudo ./run_switch_p4_<version>.sh`


## target_program

Up to now there is just one supported P4 program in this repository: A ROHC compressor/decompressor.


