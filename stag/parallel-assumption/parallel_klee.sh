STARTTIME=$(date +%s%N)

bash run-klee.sh 11 &
bash run-klee.sh 12 &
bash run-klee.sh 21 &
bash run-klee.sh 22 &
wait 

ENDTIME=$(date +%s%N)
ELAPSED_TIME=$((($ENDTIME - $STARTTIME)/1000000))

echo $1 $ELAPSED_TIME
