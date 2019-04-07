STARTTIME=$(date +%s%N)

#frama-c -slice-calls printf $1.c  -then-on 'Slicing export' -print -ocode sliced.c > /dev/null

#llvm-gcc -I ../../include -emit-llvm -c -g -O3 $1.c
#klee --search=dfs --no-output $1.o

clang -I ../../include -emit-llvm -c -g $1.c
/home/osboxes/klee-3.4/klee_build_dir/bin/klee --search=dfs --no-output --warnings-only-to-file $1.bc



ENDTIME=$(date +%s%N)
ELAPSED_TIME=$((($ENDTIME - $STARTTIME)/1000000))

echo $1 $ELAPSED_TIME
