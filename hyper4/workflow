WORKFLOW:

Using bmv2:
- update code
- run: p4c-bmv2 --json HyPer4.json HyPer4.p4
- run mininet simulation: 
  sudo python ~/p4factory/submodules/bm/mininet/1sw_demo.py \
  --behavioral-exe ~/p4factory/submodules/bm/targets/simple_switch/simple_switch \
  --json ~/Documents/p4-hypervisor/src/HyPer4.json
- enter CLI:
  sudo ~/p4factory/submodules/bm/tools/runtime_CLI.py --json HyPer4.json \
  [--thrift-port <thrift port#>]
  OR [preferred]:
  sudo ~/p4factory/submodules/bm/targets/simple_switch/sswitch_CLI HyPer4.json \
  <thrift port#>

Using bmv1:
- if necessary, create new target:
  ~/p4factory/tools/newtarget.py HyPer4
- update code (in ~/Documents/p4-hypervisor/src)
- copy files to p4factory/targets/HyPer4: ./bmv1_copy.sh
- cd ~/p4factory/targets/HyPer4
- compile: make bm
- run mininet simulation:
  sudo python ../../mininet/1sw_demo.py --behavioral-exe $PWD/behavioral-model
- enter CLI:
  python ../../cli/pd_cli.py -p HyPer4 -i p4_pd_rpc.HyPer4 \
  -s $PWD/tests/pd_thrift:$PWD/../../testutils "$@" [-c localhost:<port number>]
