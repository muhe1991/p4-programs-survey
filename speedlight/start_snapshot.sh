#! /bin/bash

set -e

if [ $# -lt 3 ]; then
	echo "Usage: ./start_snapshot.sh HH MM numports [passed arguments]"
	exit 1
fi

HH=$1
MM=$2
NUMPORTS=$3

shift 3

CORES=$((`nproc` - 1))
STEP=$((${NUMPORTS}/${CORES}))

NUM_HIGH=$((${NUMPORTS} - (${STEP} * ${CORES})))
NUM_LOW=$((${CORES} - ${NUM_HIGH}))

PORT=1
for (( i=0; i < ${NUM_HIGH}; i++)) 
do
		echo "high starting ${PORT}, ending inclusive: $((${PORT} + ${STEP}))"
        sudo out/startsnap -d veth1 ${HH} ${MM} ${PORT} $((${PORT} + ${STEP} + 1)) $@ &
        PORT=$((${PORT} + ${STEP} + 1))
done
if [ "$STEP" != 0 ]; then
	for (( i=0; i < ${NUM_LOW}; i++))
	do
			echo "starting: ${PORT}, ending inclusive: $((${PORT} + ${STEP} - 1))" 
	        sudo out/startsnap -d veth1 ${HH} ${MM} ${PORT} $((${PORT} + ${STEP})) $@ &
	        PORT=$((${PORT} + ${STEP}))
	done
fi


wait
