#!/bin/bash

# Generate configuration of HyPer4:
# - supports $1 stages and $2 primitives per stage
#
# David Hancock
# University of Utah
# dhancock@cs.utah.edu

if [[ $# -lt 2 ]] ; then
  echo 'usage: '$0' <max # stages> <max # primitives per stage>'
  exit 0
fi

rm -rf ../p4src/
mkdir ../p4src/
mkdir ../p4src/includes

./p4t -ns $1 -np $2 -o ../p4src/hp4.p4 hp4.p4t
cd includes/
for f in *.p4t;
do
  echo 'processing '$f' -> '${f%.p4t}.p4
  ../p4t -ns $1 -np $2 -o ../../p4src/includes/${f%.p4t}.p4 $f
done
