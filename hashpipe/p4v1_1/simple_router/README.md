# P4 v1.1 Simple Router

## Description

This program is a version of the now famous simple_router program, written
according to the P4 v1.1 specification. In addition to the original
simple_router, this version can keep track of the number of IPv4 packets dropped
because of an expired TTL. This was added to illustrate some of P4 v1.1 more
advanced capabilities.
For more information on P4 v1.1, please refer to [p4.org] (http://p4.org/spec/).

Look at the [P4 program] (p4src/simple_router.p4) and observe some of the P4
v1.1 additions:
- strong typing in header type definitions and action declarations
- assignment with `=` instead of `modify_field` (extension to the v1.1 spec)
- register indexing
- support for the ternary operator (extension to the v1.1 spec)

### Running the demo

We provide a small demo to let you test the program. Before trying to run the
demo, please make sure that your [env.sh] (../env.sh) file is up-to-date.

To run the demo:
- start the switch in Mininet with `./run_switch.sh`
- in another terminal, populate the table entries with `./add_entries.sh`
- you should now be able to ping h2 from h1 by typing `h1 ping h2` in the
  Mininet CLI

Once you have the basic demo running, you can start sending packets with a TTL
of 1, activate packet drop tracking in the switch and observe the count go
up. To do this:
- activate the tracking with `./register_on_off.sh on`
- send ICMP packets with a TTL of 1 from the Mininet CLI: `h1 ping h2 -t 1`. The
  packets are now dropped by the switch, so you should not be able to observe a
  reply

To get the drop count, simply run `./read_register.sh`.
