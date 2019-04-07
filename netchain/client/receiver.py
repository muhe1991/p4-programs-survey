import socket
import struct
import time
import thread
import sys
import os
lib_path = os.path.abspath(os.path.join('../controller'))
sys.path.append(lib_path)
from nc_config import *

rs = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
rs.bind((sys.argv[1], REPLY_PORT))

counter = 0
def counting():
    last_counter = 0
    while True:
        print (counter - last_counter), counter
        sys.stdout.flush()
        last_counter = counter
        time.sleep(1)
thread.start_new_thread(counting, ())

def main():
    global counter
    last_count = 0
    current_time = time.time()
    while (1):
        packet_received, addr = rs.recvfrom(2048)
        op_field = int(struct.unpack("B", packet_received[0])[0])
        counter = counter + 1
        continue
        
if __name__ == "__main__":
    main()