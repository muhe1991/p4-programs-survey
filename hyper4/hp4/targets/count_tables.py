#!/usr/bin/python

import argparse

parser = argparse.ArgumentParser(description='Counts distinct tables referenced in commands files')
parser.add_argument("filename")
parser.add_argument("--list", help="print list of tables", action="store_true")
parser.add_argument("--sum", help="print summary", action="store_true")

args = parser.parse_args()

f = open(args.filename, 'r')
tables = set()
for line in f:
  if line.split()[0] != "mirroring_add":
    tables.add(line.split()[1])
f.close()

if args.list:
  for t in tables:
    print(t)

if args.sum:  
  print("%d distinct tables in %s" % (len(tables), args.filename))
