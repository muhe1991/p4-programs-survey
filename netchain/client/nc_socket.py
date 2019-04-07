import socket
import struct
import time
import thread
import sys
import os
lib_path = os.path.abspath(os.path.join('../controller'))
sys.path.append(lib_path)
from nc_config import *
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

counter = 0
def counting():
    last_counter = 0
    while True:
        print (counter - last_counter), counter
        sys.stdout.flush()
        last_counter = counter
        time.sleep(1)
thread.start_new_thread(counting, ())

def get_chain_of_key(key, chains):
    for i in chains:
        if key in ENTRY[i]:
            return chains[i]
    return []

def read_req(chains, num_kv, size_vgroup):
    global counter
    value = 0
    request_type = NC_READ_REQUEST

    op_field = struct.pack("B", request_type)
    sc = 4
    sc_field = struct.pack("B", sc)
    seq = 0
    seq_field = struct.pack("H", seq)
    
    index = 0
    while (1):
        key = ENTRY[1][index]
        value = 0

        vgroup = (key - 2018) / (num_kv/size_vgroup)
        vgroup_field = struct.pack(">H", vgroup)

        chain = get_chain_of_key(key, chains)
        ipx = [[] for i in range(len(chain))]
        for i in range(len(chain)):
            ipx[i] = [int(j) for j in chain[i].strip().split('.')]

        s0_field = struct.pack("BBBB", ipx[0][0], ipx[0][1], ipx[0][2], ipx[0][3])
        
        s1_field = struct.pack("BBBB", ipx[1][0], ipx[1][1], ipx[1][2], ipx[1][3])
        
        s2_field = struct.pack("BBBB", ipx[2][0], ipx[2][1], ipx[2][2], ipx[2][3])

        end_field = struct.pack("BBBB", 0,0,0,0)

        key_highBytes = key >> 64
        key_lowBytes = key ^ (key_highBytes << 64)
        key_field = struct.pack(">Q", key_highBytes) + struct.pack(">Q", key_lowBytes)

        value_highBytes = value >> 64
        value_lowBytes = value ^ (value_highBytes << 64)
        value_field = struct.pack(">Q", value_highBytes) + struct.pack(">Q", value_lowBytes)

        packet_to_send = s2_field + s1_field + s0_field + end_field + op_field + sc_field + seq_field + key_field + value_field  + vgroup_field
        
        read_ip = chain[len(chain) - 1]
        #print "send out."
        s.sendto(packet_to_send, (read_ip, NC_PORT))
        counter = counter + 1    
        time.sleep(0.01)
        index = (index + 1) % num_kv
def write_req(chains, num_kv, size_vgroup):
    global counter
    request_type = NC_WRITE_REQUEST
    op_field = struct.pack("B", request_type)
    sc = 4
    sc_field = struct.pack("B", sc)
    seq = 0
    seq_field = struct.pack("H", seq)

    index = 0
    while (1):
        key = ENTRY[1][index]
        value = 222

        vgroup = (key - 2018) / (num_kv/size_vgroup)
        vgroup_field = struct.pack(">H", vgroup)

        chain = get_chain_of_key(key, chains)
        ipx = [[] for i in range(len(chain))]
        for i in range(len(chain)):
            ipx[i] = [int(j) for j in chain[i].strip().split('.')]

        s0_field = struct.pack("BBBB", ipx[0][0], ipx[0][1], ipx[0][2], ipx[0][3])
        
        s1_field = struct.pack("BBBB", ipx[1][0], ipx[1][1], ipx[1][2], ipx[1][3])
        
        s2_field = struct.pack("BBBB", ipx[2][0], ipx[2][1], ipx[2][2], ipx[2][3])

        end_field = struct.pack("BBBB", 0,0,0,0)

        key_highBytes = key >> 64
        key_lowBytes = key ^ (key_highBytes << 64)
        key_field = struct.pack(">Q", key_highBytes) + struct.pack(">Q", key_lowBytes)

        value_highBytes = value >> 64
        value_lowBytes = value ^ (value_highBytes << 64)
        value_field = struct.pack(">Q", value_highBytes) + struct.pack(">Q", value_lowBytes)

        packet = s0_field + s1_field + s2_field + end_field + op_field + sc_field + seq_field + key_field + value_field  + vgroup_field
        write_ip = chain[0] 
    
        s.sendto(packet, (write_ip, NC_PORT))
        counter = counter + 1
        time.sleep(0.01)
        index = (index + 1) % num_kv
        
if __name__ == "__main__":
    op = sys.argv[1]
    if (op == "read"):
        vnode_num = int(sys.argv[2])
        vring_file = sys.argv[3]
    elif (op == "write"):
        vnode_num = int(sys.argv[2])
        vring_file = sys.argv[3]
    num_kv = int(sys.argv[4])
    size_vgroup = int(sys.argv[5])
    ## Set vring...
    chains = {}
    with open(vring_file, "r") as f:
        for i in range(vnode_num):
            line = f.readline().split()
            chains[int(line[0])] = line[1:]
    
    if (op == "read"):
        read_req(chains, num_kv, size_vgroup)
    elif (op == "write"):
        write_req(chains, num_kv, size_vgroup)