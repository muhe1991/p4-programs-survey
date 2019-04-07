#!/usr/bin/python

from p4_hlir.main import HLIR
import argparse

parser = argparse.ArgumentParser(description='HP4 Compiler')
parser.add_argument('source', metavar='source', type=str,
                        help='A source file to include in the P4 program.')
parser.add_argument('--ac', help='Where to write annotated commands file',
                    type=str, action="store", required=True)
parser.add_argument('--SEB', help='Number of standard extracted bytes',
                    type=int, action="store", default=20)
args = parser.parse_args()

h = HLIR(args.source)
h.build()

# We need a separate file that has commands like this:
#   print("table_set_default t_norm_SEB a_norm_SEB")
# and all others that are program independent but make
# HP4 go
# Others:
#  mirroring_add <port#> <port#>
# for all ports
#  table_set_default t_prep_deparse_SEB a_prep_deparse_SEB
# etc.

total = 0

for call in h.p4_parse_states['start'].call_sequence:
  if call[0].value == 'extract':
    total +=  call[1].header_type.length
  elif call[0].value == 'set':
    print("set_metadata statement not yet supported")

if total < args.SEB:
  print("table_add parse_control set_next_action [program ID] 0 0 => [PROCEED]")
else:
  print("table_add parse_control extract_more [program ID] 0 0 => %d 0" % total)
  print("table_add parse_control set_next_action [program ID] %d 0 => [PROCEED]" % total)



print("Success")
