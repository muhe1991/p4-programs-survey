#!/usr/bin/python

# Generate report showing number of tables declared for every configuration
# of HyPer4 from one stage and one primitive per stage, to [numstages] stages
# and [numprimitives] primitives per stage
#
# David Hancock
# University of Utah
# dhancock@cs.utah.edu

import csv
import argparse

parser = argparse.ArgumentParser(description='HP4 Tables Reporter')
parser.add_argument('--numstages', help='Max number of match-action stages',
                    type=int, action="store", default=3)
parser.add_argument('--numprimitives', help='Max number of primitives per compound action',
                    type=int, action="store", default=3)

args = parser.parse_args()

r = open('results_tables.csv', 'w')
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
    fname = '../p4src/test/config_' + str(ns) + str(npps) + '/numtables'
    f = open(fname, 'r')
    nppslist.append(f.read().splitlines()[0])
    f.close()
  writer.writerow(nppslist)

r.close()
