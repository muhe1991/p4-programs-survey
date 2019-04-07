STARTTIME=$(date +%s%N)

#frama-c -slice-calls klee_print_once $1.c  -then-on 'Slicing export' -print -ocode sliced.c > /dev/null

#bash run-klee.sh dapper_1_1_1 &
#bash run-klee.sh dapper_1_1_1 &
#bash run-klee.sh dapper_1_2 &
#bash run-klee.sh dapper_2_1 &
#bash run-klee.sh dapper_2_2 &
bash run-klee.sh dapper-p1t1 &
bash run-klee.sh dapper-p1t2 &
bash run-klee.sh dapper-p1t3 &
bash run-klee.sh dapper-p2t1 &
bash run-klee.sh dapper-p2t2 &
bash run-klee.sh dapper-p2t3 &

wait 

#clang -I ../../include -emit-llvm -g $1.c
#opt -O3 -o opt.bc $1.bc
#/home/osboxes/klee-3.4/klee_build_dir/bin/klee --search=dfs --no-output --warnings-only-to-file --optimize opt.bc

ENDTIME=$(date +%s%N)
ELAPSED_TIME=$((($ENDTIME - $STARTTIME)/1000000))

echo $1 $ELAPSED_TIME
