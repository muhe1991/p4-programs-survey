#!/bin/bash

# If cell number supplied as first argument, this script will notify via SMS
# when finished

PROJ=${PWD##*/}

var=$( { time p4c-bmv2 --json $PROJ.json p4src/$PROJ.p4; } 2>&1 )

if [ $# -eq 1 ]
  then
    echo "${var}" > output.txt
    output=$( { tail -n 3 output.txt; } )
    rm output.txt
    curl http://textbelt.com/text -d number=$1 -d "message=hp4 compilation complete: $output"
  else
    echo "${var}"
fi
