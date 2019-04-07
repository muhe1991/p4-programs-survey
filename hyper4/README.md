# HyPer4

HyPer4 is a *portable* and *dynamic* solution for virtualizing the [P4-programmable][1] data plane.

Virtualization can take a single physical data plane and present the illusion of multiple data planes.  Each virtual data plane on a network device can host a different packet processing program, i.e., function.  These functions can be chained together in complex ways for arbitrary [compositions][2].  Or they can be isolated from each other in distinct [network slices][3].  Support for network function composition permits a modular development process, yielding advantages in independent debugging and optimization efforts.  Support for slices permits support for multiple tenants, or mixes of research experiments and production operations, where each slice could involve completely distinct protocol headers and functions.

The main development effort has been the HyPer4 *persona*, a P4 program capable of emulating other P4 programs.  Other components of HyPer4 include a *data plane management unit*(DPMU), which is not yet implemented, but in concept is similar in purpose to the [Flowvisor][3] controller/switch proxy.  The DPMU intercepts commands meant for foo.p4 and, assuming foo.p4 is currently being emulated by the HyPer4 persona, translates the commands to those relevant to hp4_persona.p4.  The DPMU also provides resource management and isolation support for multiple programs being emulated by the persona at the same time.

## Related Work

The [Flowvisor][3] project virtualizes the *control plane* and relies on [OpenFlow][4], which has a fixed data plane (relative to [P4][1]).

[References]: #

[1]: http://arxiv.org/pdf/1312.1719.pdf "P4: Programming Protocol Independent Packet Processors"
[2]: https://www.usenix.org/system/files/conference/nsdi13/nsdi13-final232.pdf "Composing Software Defined Networks"
[3]: http://archive.openflow.org/downloads/technicalreports/openflow-tr-2009-1-flowvisor.pdf "FlowVisor: A Network Virtualization Layer"
[4]: http://www3.cs.stonybrook.edu/~vyas/teaching/CSE_534/Spring13/papers/OpenFlow.pdf "OpenFlow: Enabling Innovation in Campus Networks"
