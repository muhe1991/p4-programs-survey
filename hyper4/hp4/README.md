# HyPer4

HyPer4 is a P4 program that acts as a hypervisor, in that it is capable of emulating other (simple) P4 programs.

Conceptually, we think of P4 programs as having *structure* -- the .P4 source -- and *state* --
the runtime-supplied table entries and default actions that may govern flow of execution
within the framework provided by the structure.

HyPer4 aims to provide a generalized structure to allow arbitrary packet processing
activities, as directed by state, where a collection of such activities can represent
entire P4 programs.  Thus .p4 source is converted ("compiled") into table operations
consumable by HyPer4.

We have converted two P4 programs this way:
- A simple L2 switch program
  - based on dest MAC address, it forwards out a specific port, or does a multicast
- A simple router
  - based on dest IP address, it forwards out a specific port, rewrites the source
    MAC address, decrements the TTL, and recomputes the IPv4 checksum

An IPv4 checksum routine has been implemented directly in HyPer4, but in the future,
general checksums (i.e. using arbitrary portions of the packet for the calculation)
will be possible.

These two programs are used in four demos, all in the /hp4 directory:

1. Run the L2 switch program via HyPer4:  
   ```
   run\_l2\_switch\_demo.sh  
   ```   
   From the mininet prompt, you may verify connectivity between the three hosts.

2. Run the simple router program via HyPer4:
   ```
   run\_simple\_router\_demo.sh
   ```
   From the mininet prompt, you may verify connectivity between h1<->h2, but  
   adding connectivity to/from h3 is left as an exercise.  (This may be  
   difficult to do until I add some information about the HyPer4 table operations  
   required, but the file to edit is in ./targets/simple_router/commands.txt)
   
3. Initialize HyPer4 to contain the L2 switch program as well as an extended  
   version of the same program; swap between the two at will, observing the impact  
   on connectivity: see two\_progs\_sequential\_demo.txt for detailed instructions.

4. Run both the L2 switch program AND the simple router program simultaneously,  
   each taking action on a different set of packets (separated by ingress port):
   ```
   run\_two\_progs\_demo.sh
   ```
   From the mininet prompt, you may verify connectivity between h1, h2, and h3  
   (these are using the L2 switch program), and between h4 and h5 (these are  
   using the simple router program).  h6 is grouped with h4 and h5 but, just  
   as in demo #2, we have not supplied the table entries required to establish  
   connectivity to/from h6.  You are welcome to give it a try; edit  
   ./targets/two\_progs\_parallel.

There is much work to be done (templatizing HyPer4, making a "compiler" as well
as a control plane translator, expanding the coverage of HyPer4 over more
primitives, table match types, etc.).  But hopefully, these demos provide an idea
of what HyPer4 might be capable of some day.
