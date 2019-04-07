STARTTIME=$(date +%s%N)

llvm-gcc -I ../../include -emit-llvm -c -g $1.c
klee --search=dfs --no-output $1.o

ENDTIME=$(date +%s%N)
ELAPSED_TIME=$((($ENDTIME - $STARTTIME)/1000000))

echo $1 $ELAPSED_TIME
