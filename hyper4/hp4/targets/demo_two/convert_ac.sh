#!/bin/bash

TEST_SUFFIX=

if [ $# -eq 1 ]
  then
    if [[ $1 == "--test" ]]; then
      TEST_SUFFIX="_test"
    fi
fi

~/hp4-src/tools/ac_to_c.py --input commands_annotated_d2_A.txt --output A$TEST_SUFFIX.txt --progID 1

~/hp4-src/tools/ac_to_c.py --input commands_annotated_d2_B_1.txt --output B_1$TEST_SUFFIX.txt --progID 2 --virt_ports 65 66 67 68

~/hp4-src/tools/ac_to_c.py --input commands_annotated_d2_B_2.txt --output B_2$TEST_SUFFIX.txt --progID 3 --virt_ports 69 70 71 72
