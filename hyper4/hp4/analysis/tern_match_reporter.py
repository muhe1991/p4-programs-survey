#!/usr/bin/python

# Generate ternary match report for single configuration of HyPer4 starting
#  with hp4/p4src/hp4.p4 and also including the hp4/p4src/includes directory.
#
# This tool does not currently make the correct measurement.  It totals up
# bits used in all possible ternary matches in HyPer4, but we need to look
# at a nano log for a single representative packet and measure the bits
# used in a live test.
#
# David Hancock
# University of Utah
# dhancock@cs.utah.edu

import csv
import argparse
from p4_hlir.main import HLIR

parser = argparse.ArgumentParser(description='HP4 Ternary Match Reporter')
parser.add_argument('--nano', help='path to nano log input file',
                    type=str, action="store", required=True)
parser.add_argument('--output', help='path to csv output file',
                    type=str, action="store", default="results_ternmatch.csv")
parser.add_argument('-v', '--verbose', help='increase stdout verbosity',
                    action="store_true")

args = parser.parse_args()

h = HLIR('../p4src/hp4.p4')
h.build(analyze=False)

r = open(args.output, 'w')
writer = csv.writer(r)
writer.writerow(['Packet', 'Table', 'Field', 'Bitwidth'])

n = open(args.nano, 'r')
reader = csv.reader(n)

packetevents = {}

for line in reader:
  packetid = int(line[4].split()[1])
  if packetid not in packetevents.keys():
    packetevents[packetid] = []
  if 'TABLE' in line[0].split()[1]:
    start = line[6].index('(') + 1
    packetevents[packetid].append(line[6][start:-1])

tracetotal = 0

for packetid in packetevents:
  packettotal = 0
  packet_tern_fields = []
  for table in packetevents[packetid]:
    for match_field in h.p4_tables[table].match_fields:
      if match_field[1].value == 'P4_MATCH_TERNARY':
        packettotal += match_field[0].width
        field = match_field[0].instance.name + "." + match_field[0].name
        packet_tern_fields.append((table, field, match_field[0].width))
        writer.writerow([packetid,table,field,match_field[0].width])
  print("packet %d used %d bits in ternary matching" % (packetid, packettotal))
  if args.verbose:
    print("packet %d experienced the following ternary matches:" % packetid)
    for tern_match in packet_tern_fields:
      print("\t%s, %s, %s" % (tern_match[0], tern_match[1], str(tern_match[2])))
  tracetotal += packettotal

avg = float(tracetotal) / float(len(packetevents))
print("Average bits used for ternary matching in %s: %f" % (args.nano, avg))
print("Output: %s" % args.output)

r.close()
n.close()
