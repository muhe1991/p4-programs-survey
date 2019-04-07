#!/usr/bin/python

# Packet Header Vector Reporter.  Generate packet header vector size report
# for HyPer4 (in the hp4/p4src directory, NOT in hp4/p4src/test/confg_XY).
#
# David Hancock
# University of Utah
# dhancock@cs.utah.edu

import csv
from p4_hlir.main import HLIR

h = HLIR('../p4src/hp4.p4')
h.build(analyze=False)

r = open('results_phv.csv', 'w')
writer = csv.writer(r)
writer.writerow(['Header', 'Length (B)', 'Notes'])

isstack = False
stackcounter = 0
total = 0

for hinst in h.p4_header_instances:
  bitcounter = 0
  for field in h.p4_header_instances[hinst].header_type.layout:
    bitcounter += h.p4_header_instances[hinst].header_type.layout[field]
  if bitcounter != (h.p4_header_instances[hinst].header_type.length * 8):
    print("ERROR: bitcounter, header_type.length mismatch for %s" % hinst)
    exit(1)
  if isstack:
    if '[next]' in hinst:
      isstack = False
      writer.writerow([h.p4_header_instances[hinst].base_name, str(stackcounter * h.p4_header_instances[hinst].header_type.length), 'stack'])
      total += stackcounter * h.p4_header_instances[hinst].header_type.length
      stackcounter = 0
    else:
      stackcounter += 1
  elif '[0]' in hinst:
    isstack = True
    stackcounter = 1
  elif '[last]' not in hinst:
    writer.writerow([hinst, str(h.p4_header_instances[hinst].header_type.length)])
    total += h.p4_header_instances[hinst].header_type.length
print("Total: %d bytes" % total)
