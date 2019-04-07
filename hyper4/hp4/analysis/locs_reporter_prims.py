#!/usr/bin/python

# Generate report showing average lines of code per primitive
# for every configuration of HyPer4 in the
#  hp4/p4src/test directory from one stage, one primitive per stage to
#  [numstages] stages and [numprimitives] primitives per stage
#
# Assumptions:
#  1. Implemented primitives are:
#       modify_field
#       add_header
#       add_to_field
#       truncate
#       drop
#  2. The files implementing these primitives are named <primitive name>.p4
#  3. These primitive names are each found only once in each results_byfile.csv
#
# David Hancock
# University of Utah
# dhancock@cs.utah.edu

import csv
import argparse

parser = argparse.ArgumentParser(description='HP4 Primitives LoC Reporter')
parser.add_argument('--numstages', help='Max number of match-action stages',
                    type=int, action="store", default=5)
parser.add_argument('--numprimitives', help='Max number of primitives per compound action',
                    type=int, action="store", default=9)

args = parser.parse_args()

r = open('results_prims.csv', 'w')
writer = csv.writer(r)
headerrow = []
for i in range(1, args.numstages + 1):
  toappend = str(i) + " stage"
  if i > 1:
    toappend += "s"
  headerrow.append(toappend)
writer.writerow(headerrow)

for npps in range(1, args.numprimitives + 1):
  nppslist = []
  for ns in range(1, args.numstages + 1):
    total = 0
    fname = '../p4src/test/config_' + str(ns) + str(npps) + '/results_byfile.csv'
    f = open(fname, 'r')
    reader = csv.reader(f)
    reader.next()

    for line in reader:
      if 'modify_field' in line[1] or \
         'add_header' in line[1] or \
         'add_to_field' in line[1] or \
         'truncate' in line[1] or \
         'drop' in line[1]:
           total += int(line[4])
        
    avg = float(total) / 5.0
    nppslist.append(avg)
    f.close()
  writer.writerow(nppslist)

r.close()
