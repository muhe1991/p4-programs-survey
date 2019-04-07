import sys
import os.path
import re
from struct import *
import math

def main():
    
    if len(sys.argv) != 4:
        param = len(sys.argv) - 1
        print "Invalid parameter number. Expected 3 got %d" % param
        print "Usage python parser_and_calculate.py <log_file> <regex1> <samples_num>"
        return
    
    file_log = sys.argv[1] 
    file_ = open(file_log, "r")
    patern = sys.argv[2]
    samples = sys.argv[3]
    print(samples)
    first_match = True
    cnt = 0
    time_array = []
    for line in file_:
        if cnt < int(samples):
            if re.match(patern, line):
                if not first_match:
                    time = str(re.sub(patern, '', line)).strip()
                    time = int(re.match("[0-9]+", time).group(0).strip())
                    time_array.append(time)
                    cnt = cnt + 1
                else:
                    first_match = not first_match
        else:
            break

    avg = sum(time_array)/len(time_array)
    print "Average time for #%d packets: %f usec" % (len(time_array), avg)
    sigma_sq = []
    for i in time_array:
        sigma_sq.append((i-avg)**2)

    sigma_sq_mean = sum(sigma_sq)/len(sigma_sq)/len(sigma_sq)
    
    print "Mean variance for #%d packets: %f usec" % (len(sigma_sq), sigma_sq_mean)
    print "Mean Deviation for #%d packets: %f usec" % (len(sigma_sq), math.sqrt(sigma_sq_mean))

if __name__ == '__main__':
    main()

