import sys
import numpy as np
import matplotlib.pyplot as plt

def draw(num_vgroup, plot_id):
    plt.figure(plot_id)
    plt.ylim(0.0, 210.0)

    fin = open("../logs/"+num_vgroup+".tmp_write_receive.log", "r")
    count = 0
    y = []
    for line in fin.readlines():
        s_line = line.strip('\n').split()
        count = count + 1
        y.append(int(s_line[0]))
    fin.close
    fin = open("../logs/"+num_vgroup+".tmp_read_receive.log", "r")
    count = 0
    for line in fin.readlines():
        s_line = line.strip('\n').split()
        if (count < len(y)):
            y[count] = y[count] + int(s_line[0])
        count = count + 1


    x = range(1,len(y)-1)
    y = y[1:len(y)-1]
    print x
    print y
    plt.plot(x,y)
    plt.title(str(num_vgroup)+" Virtual Group")
    plt.xlabel('Time (s)')
    plt.ylabel('Throughput (QPS)')

def usage():
    print "Usage:"
    print "    python plot.py [number of virtual groups] (e.g. python plot.py 20)"
    return 

if __name__ == "__main__":
    if (len(sys.argv) != 2):
        usage()
        quit()
    draw(sys.argv[1], 1)
    plt.show()