# Resubmit

## Description

This program illustrates as simply as possible how to use the `resubmit()`
primitive. This primitive is used to make a packet go twice through the ingress
pipeline. For more information, please refer to the P4 specification.

The P4 program only consists of an ingress pipeline, with 2 tables:
`t_ingress_1` and `t_ingress_2`. When a packet enters the pipeline, the
following happens (based on the P4 program and the [commands.txt] (commands.txt)
files):
- the packet hits `table_ingress_1` and the egress port is set to 2.
- the packet hits `table_ingress_2`, `mymeta.f1` is set to 1 and the
  `resubmit()` primitive is called. Because `mymeta` is resubmitted along with
  the packet, `mymeta.f1` will now be equal to 1 for the second pass.
- the packet hits `table_ingress_1`, this time the egress port is set to 3.
- the packet hits `table_ingress_2` which is a no-op.

### Running the demo

We provide a small demo to let you test the program. It consists of the
following scripts, which you need to run one after the other, in 2 separate
terminals:
- [run_switch.sh] (run_switch.sh): compile the P4 program and starts the switch,
  also configures the data plane by running the CLI [commands] (commands.txt).
- [send_and_receive.py] (send_and_receive.py): send a packet on port 0 (veth1),
  wait for the forwarded packet on port 3 (veth7).
