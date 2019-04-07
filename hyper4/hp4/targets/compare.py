#!/usr/bin/python

import argparse
import sys

parser = argparse.ArgumentParser(description='Counts distinct tables referenced in commands files')
parser.add_argument("filename1")
parser.add_argument("filename2")

args = parser.parse_args()

f1 = open(args.filename1, 'r')
f2 = open(args.filename2, 'r')

set1 = set()
set2 = set()
for line in f1:
  set1.add(line)
f1.close()
for line in f2:
  set2.add(line)
f2.close()

print("Items in %s not in %s:" % (args.filename1, args.filename2))
for x in set1:
  if x not in set2:
    sys.stdout.write(x)
print("Items in %s not in %s:" % (args.filename2, args.filename1))
for x in set2:
  if x not in set1:
    sys.stdout.write(x)
print("Items in both %s and %s:" % (args.filename1, args.filename2))
for x in set1:
  if x in set2:
    sys.stdout.write(x)
