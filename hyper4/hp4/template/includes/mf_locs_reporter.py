#!/usr/bin/python

import csv

r = open('results_mf.csv', 'w')
writer = csv.writer(r)
headerrow = ["1","2","3","4","5"]
writer.writerow(headerrow)

for npps in range(1, 10):
  nppslist = []
  for ns in range(1, 6):
    fname = 'mf' + str(ns) + str(npps) + '.csv'
    f = open(fname, 'r')
    reader = csv.reader(f)
    reader.next()
    nppslist.append(reader.next()[4])
    f.close()
  writer.writerow(nppslist)

r.close()
