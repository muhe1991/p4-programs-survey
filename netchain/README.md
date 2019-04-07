# net-chain
## 0. Introduction<br>
- BMV2-based simple implementation of NetChain (related paper can be found here: https://www.usenix.org/conference/nsdi18/presentation/jin).

## 1. Obtain required software<br>
- Firstly, you need to get the p4 compiler from Github, and install required dependencies.<br>
  > git clone https://github.com/p4lang/p4c-bm.git p4c-bmv2<br>
  > cd p4c-bmv2<br>
  > sudo pip install -r requirements.txt<br>
- Secondly, you need to get the behavior model of p4 from github, install dependencies and compile the behavior model.<br>
  > git clone https://github.com/p4lang/behavioral-model.git bmv2<br>
  > cd bmv2<br>
  > install_deps.sh<br>
  > ./autogen.sh<br>
  > ./configure<br>
  > make<br>
- Finally, you need to install some other tools which are used in this simulation.<br>
  > sudo apt-get install mininet python-ipaddr<br>
  > sudo pip install scapy thrift networkx<br>

## 2. Content<br>
   - client<br>
     - client/nc_socket.py<br>
     - client/receiver.py<br>
     - clinet/set_arp.sh<br>
   - controller<br>
     - controller/config<br>
       - controller/config/topo.txt<br>
       - controller/config/vring.txt<br>
       - controller/config/config.xml<br>
       - controller/config/commands[_1,_2,_3]*.txt<br>
     - controller/nc_config.py<br>
     - controller/p4_mininet.py<br>
     - controller/run_test.py<br>
     - controller/exe_cmd.py<br>
     - controller/fail_recovery.py<br>
     - controller/plot.py<br>
   - p4src<br>
     - p4src/includes<br>
       - p4src/includes/checksum.p4<br>
       - p4src/includes/defines.p4<br>
       - p4src/includes/headers.p4<br>
       - p4src/includes/parsers.p4<br>
     - p4src/netchain.p4<br>
     - p4src/routing.p4<br>
   - logs<br>
   - .gitignore<br>
   - README.md<br>

## 3. How to run<br>
- Install required software and dependency for P4 (P4-14).<br>
- Make sure the directory informations are correct in
  > controller/config/config.xml.<br>
- Go to directory controller, you can simply run program in normal mode: 
  > sudo python run_test.py normal.
- Or you can run program in failure recovery mode: 
  > sudo python run_test.py failure.
- The program produces results for failure recovery at logs/. The format of the files is 
  > [number of virtual groups].tmp_[read/write]_[send/receive].log.
- You can draw figures by running: 
  > python plot.py [number of virtual groups].
