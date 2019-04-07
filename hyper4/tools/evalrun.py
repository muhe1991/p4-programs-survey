#!/usr/bin/python

# Takes two pcap files, extracts timestamps, and calculates the average and
# standard deviation of the differences between timestamps
#
# Assumption is that file 1 includes timestamps of packets received on the inbound
# switch interface; file 2 includes timestamps of the corresponding packets sent
# out the outbound switch interface.
#
# DAVID HANCOCK
# University of Utah

import sys
import os
import datetime
import time
import numpy

# get run#
if len(sys.argv) < 2:
  print("usage: %s <run #>\n" % sys.argv[0])
  exit()

# construct filenames (1 for eth1, 1 for eth2)
filestart1 = "run" + sys.argv[1] + "-eth1"
filestart2 = "run" + sys.argv[1] + "-eth2"

file1pcap = filestart1 + ".pcap"
file2pcap = filestart2 + ".pcap"
file1txt = filestart1 + ".txt"
file2txt = filestart2 + ".txt"

# use tcpdump -r to convert .pcap files to .txt
execstr1 = "tcpdump -r " + file1pcap + " > " + file1txt
execstr2 = "tcpdump -r " + file2pcap + " > " + file2txt
os.system(execstr1)
os.system(execstr2)

times1 = []
times2 = []
diffs = []

# process the two files
with open(file1txt, 'r') as f1:
  for line in f1:
    # store the time in an array
    t = datetime.datetime.strptime( line.split()[0], "%H:%M:%S.%f" )
    times1.append( time.mktime(t.timetuple()) + (t.microsecond / 1000000.0) )
    
with open(file2txt, 'r') as f2:
  for line in f2:
    # store the time in an array
    t = datetime.datetime.strptime( line.split()[0], "%H:%M:%S.%f" )
    times2.append( time.mktime(t.timetuple()) + (t.microsecond / 1000000.0) )

# - calculate difference between corresponding timestamps
for t1, t2 in zip(times1, times2):
  diffs.append( round( (t2 - t1) * 1000, 3) )

# - calculate average, stddev and print to stdout
arr = numpy.array(diffs)
#for num in diffs:
#  print(num)
print("avg: %.3fms, std: %.3f, count: %i" % (numpy.mean(arr), numpy.std(arr), int(len(diffs)) ))
