import os, logging, sys, subprocess, argparse, time
import xml.etree.ElementTree as xmlparse
from nc_config import *
from exe_cmd import *
from topo import *
from fail_recovery import *


###########################################
## get parameters
###########################################
class Parameters:
    def __init__(self, config_file):
        root_dir = xmlparse.parse(config_file).getroot()
        self.config_file = config_file
        self.project_dir = root_dir.find("projectDir").text
        self.topology_file = self.project_dir + "/" + root_dir.find("topology").find("topologyFileName").text
        self.thrift_base_port = int(root_dir.find("thriftBasePort").text)
        self.bmv2 = root_dir.find("bmv2").text
        self.p4c_bmv2 = root_dir.find("p4cBmv2").text
        self.switch_json = self.project_dir + "/" + root_dir.find("switchJson").text
        self.num_vnode = int(root_dir.find("numVirtualNode").text)
        self.num_replica = int(root_dir.find("numReplica").text)
        self.num_kv = int(root_dir.find("numKeyValue").text)
        self.switch_p4 = self.project_dir + "/" + root_dir.find("p4src").text
        self.runtime_CLI = root_dir.find("bmv2").text + "/" + root_dir.find("runtimeCLI").text
        self.vring_file = self.project_dir + "/" + root_dir.find("topology").find("vringFileName").text
        self.register_size = int(root_dir.find("registerSize").text)
        self.size_vgroup = int(root_dir.find("sizeVirtualGroup").text)

def compile_p4_switch(parameters):
    logging.info("Generate switch json...")
    exe_cmd("%s/p4c_bm/__main__.py %s --json %s" % (parameters.p4c_bmv2, parameters.switch_p4, parameters.switch_json))
    return

def compile_all(parameters):
    compile_p4_switch(parameters)
    return


def run(parameters):
    compile_all(parameters)
    logging.info("Warm up...")
    exe_cmd("%s/targets/simple_switch/simple_switch > /dev/null 2>&1" % parameters.bmv2)
    exe_cmd("mkdir -p %s/logs/switches" % parameters.project_dir)

    logging.info("Start mininet...")
    (switches, hosts, net) = config_mininet(parameters)

    logging.info("Get chain informations...")
    chains = {}
    with open(parameters.vring_file, "r") as f:
        for i in range(parameters.num_vnode):
            line = f.readline().split()
            chains[int(line[0])] = line[1:]
    
    return (switches, hosts, net, chains)

def clean():
    print "Clean environment..."
    exe_cmd("ps -ef | grep nc_socket.py | grep -v grep | awk '{print $2}' | xargs kill -9")
    exe_cmd("ps -ef | grep NetKVController.jar | grep -v grep | awk '{print $2}' | xargs kill -9")
    exe_cmd("ps -ef | grep tcpdump | grep -v grep | awk '{print $2}' | xargs kill -9")
    exe_cmd("ps -ef | grep dist_txn | grep -v grep | awk '{print $2}' | xargs kill -9")
    exe_cmd("rm -f *.pcap")
    exe_cmd("rm -f *.out *.pyc")
    exe_cmd("rm -f *.log.txt *.log.*.txt")
    exe_cmd("rm -f tmp_send_cmd_noreply.txt tmp_send_cmd.txt")
    exe_cmd("killall lt-simple_switch >/dev/null 2>&1")
    exe_cmd("mn -c >/dev/null 2>&1")
    #exe_cmd("ps -ef | grep run.py | grep -v grep | awk '{print $2}' | xargs kill -9")
    exe_cmd("killall -9 redis-server > /dev/null 2>&1")
    exe_cmd("killall -9 redis_proxy > /dev/null 2>&1")
    exe_cmd("killall -9 cr_backend > /dev/null 2>&1")

def init_flowtable(parameters):
    role = [100, 101, 102]
    for switch_id in range(3):
        switch_ip = IP_PREFIX + str(switch_id + 1)
        switch_port = THRIFT_PORT_OF_SWITCH[switch_id]
        logging.info(switch_port)
        init_cmd = ""
        for i in range(parameters.num_kv):
            key = ENTRY[1][i]
            table_add_getAddress_cmd = "table_add get_my_address get_my_address_act " + str(key) + " => " + switch_ip + " " + str(role[switch_id])
            
            table_add_findindex_cmd = "table_add find_index find_index_act " + str(key) + " => " + str(i)
            
            register_write_value_cmd = "register_write value_reg " + str(i) + " " + str(i)
            init_cmd = init_cmd + table_add_getAddress_cmd + "\n" + table_add_findindex_cmd + "\n" + register_write_value_cmd + "\n"
        send_cmd_to_port_noreply(parameters, init_cmd, switch_port)


def send_traffic(parameters, switches, hosts, net):
    read_host_id = 0
    read_host = net.get('h%d' % (read_host_id + 1))
    read_host.sendCmd("sh %s/client/set_arp.sh" % (parameters.project_dir))
    print read_host.waitOutput()
    read_host.sendCmd("python %s/client/receiver.py 10.0.0.1 > %s/logs/%d.tmp_read_receive.log & python %s/client/nc_socket.py read %d %s %d %d > %s/logs/tmp_read_send.log &"
     % (parameters.project_dir, parameters.project_dir, parameters.size_vgroup, parameters.project_dir, parameters.num_vnode, parameters.vring_file, parameters.num_kv, parameters.size_vgroup, parameters.project_dir))
    write_host_id = 1
    write_host = net.get('h%d' % (write_host_id + 1))
    write_host.sendCmd("sh %s/client/set_arp.sh" % (parameters.project_dir))
    print write_host.waitOutput()
    write_host.sendCmd("python %s/client/receiver.py 10.0.0.2 > %s/logs/%d.tmp_write_receive.log & python %s/client/nc_socket.py write %d %s %d %d > %s/logs/tmp_write_send.log &"
     % (parameters.project_dir, parameters.project_dir, parameters.size_vgroup, parameters.project_dir, parameters.num_vnode, parameters.vring_file, parameters.num_kv, parameters.size_vgroup, parameters.project_dir))

    return (read_host,write_host)

def stop_switch(fail_switch_id, switches, hosts, net):
    fail_switch = net.get('s%d' % (fail_switch_id + 1))
    fail_switch.stop()
    return


###########################################
## run test in normal case
###########################################
def test_normal(parameters):
    (switches, hosts, net, chains) = run(parameters)
    init_flowtable(parameters)
    logging.info("Run for 60 seconds...")
    time.sleep(60)
    net.stop()
    clean()
    return

###########################################
## run test in failure case
###########################################
def test_failure(parameters, fail_switch_id):
    ###  install initial rules
    (switches, hosts, net, chains) = run(parameters)
    init_flowtable(parameters)
    ###  start sending traffic on host0
    logging.info("Sending traffic...")
    (read_host, write_host) = send_traffic(parameters, switches, hosts, net)

    ###  wait for 10 seconds
    logging.info("Wait for 10 seconds...")
    time.sleep(TENSECONDS)

    ###  stop one switch
    logging.info("Stop a switch...")
    stop_switch(fail_switch_id, switches, hosts, net)

    ###  wait for 10 seconds
    logging.info("Assume the failure is discovered in 0.5s...")
    time.sleep(0.5)
    
    ###  update rules for fast failover
    logging.info("Start failover...")
    failover(parameters, fail_switch_id, chains)

    ###  wait for 10 seconds
    logging.info("Wait for 10 seconds...")
    time.sleep(TENSECONDS)

    ###  update rules for failure recovery
    logging.info("Start failrecovering...")
    failure_recovery(parameters, fail_switch_id, chains)

    ### wait for 10 seconds
    logging.info("Wait for 10 seconds...")
    time.sleep(TENSECONDS)
    
    ###  clean environment
    read_host.monitor()
    write_host.monitor()
    net.stop()
    clean()
    return 

def usage():
    print "Usage:"
    print "    To run test in normal case: python run_test.py normal"
    print "    To run test in failure case: python run_test.py failure"
    return 

if __name__ == "__main__":
    exe_cmd("rm -f *.log.txt")
    logging.basicConfig(level=logging.INFO)
    if (len(sys.argv) != 2):
        usage()
        quit()
    config_file = "config/config.xml"
    parameters = Parameters(config_file)
    if sys.argv[1] == "normal":
        test_normal(parameters)
    elif sys.argv[1] == "failure":
        test_failure(parameters, 1)
    else:
        usage()
        quit()
