STARTTIME=$(date +%s%N)

#frama-c -slice-calls printf $1.c  -then-on 'Slicing export' -print -ocode sliced.c > /dev/null

#llvm-gcc -I ../../include -emit-llvm -c -g sliced.c
#klee --search=dfs --no-output --warnings-only-to-file sliced.o

clang -I ../../include -emit-llvm -g -c $1.c
#opt -O3 -o opt.bc $1.bc
/home/osboxes/klee-3.4/klee_build_dir/bin/klee --search=dfs --no-output --warnings-only-to-file --optimize $1.bc

ENDTIME=$(date +%s%N)
ELAPSED_TIME=$((($ENDTIME - $STARTTIME)/1000000))

echo $1 $ELAPSED_TIME
