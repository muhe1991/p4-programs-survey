#!/bin/bash

# Generate and count lines of code for every configuration of HyPer4 from
# one stage, one primitive per stage, to $1 stages and $2 primitives per stage.
#
# Requires CLOC: https://github.com/AlDanial/cloc
#
# David Hancock
# University of Utah
# dhancock@cs.utah.edu

if [[ $# -eq 0 ]] ; then
  echo 'usage: '$0' <max # stages> <max # primitives per stage>'
  exit 0
fi

cd ../template/
rm -rf ../p4src/test
mkdir ../p4src/test

for i in `seq 1 $2`;
do
  for j in `seq 1 $1`;
  do
    rm -rf ../p4src/test/config_$j$i
    mkdir ../p4src/test/config_$j$i
    mkdir ../p4src/test/config_$j$i/includes
    ./p4t -ns $j -np $i -o ../p4src/test/config_$j$i/hp4.p4 hp4.p4t
    cd includes/
    for f in *.p4t;
    do
      ../p4t -ns $j -np $i -o ../../p4src/test/config_$j$i/includes/${f%.p4t}.p4 $f
    done
    cd ..
    cloc ../p4src/test/config_$j$i/ --force-lang="C",p4 --report-file=../p4src/test/config_$j$i/results_byfile.csv --csv --by-file
    cloc ../p4src/test/config_$j$i/ --force-lang="C",p4 --report-file=../p4src/test/config_$j$i/results_sum.csv --csv
    grep -roh --include \*.p4 "^table.*{" ../p4src/test/config_$j$i/ | wc -l > ../p4src/test/config_$j$i/numtables 
  done
done
