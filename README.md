# Survey of P4 Programs

This is a repostory to store all P4 programms under our survey. 


## List of Programms

We collect P4 programs from different sources, including the tutorial of P4 community, Github public repositories, and publications with open-source


### From tutorials
* SIGCOMM 18 Tutorial
  * Basic Forwarding: __basic_forward.p4__ 
  * Basic Tunneling: __basic_tunnel.p4__
  * Explicit Congestion Notification: __ecn.p4__
  * Multi-Hop Route Inspection: __mri.p4__
  * Source Routing: __source_routing.p4__
  * Calculator: __calc.p4__
  * Load Balancing: __load_balance.p4__
* P4D2 17
  * L3 Forwarding: __ip_forward.p4__
  * ARP/ICMP Responder: __arp.p4__
* SIGCOMM 17 Tutorial
  * HULA Load Balancer: [__hula.p4__](https://github.com/p4lang/tutorials/tree/sigcomm_17/SIGCOMM_2017/exercises/hula)
  * Header bit inversion: __scrambler.p4__
* SIGCOMM 16 Tutorial
  * Heavy Hitter Detection: __heavy_hitter_1.p4__ and __heavy_hitter_2.p4__
  * ECMP: __ecmp_1.p4__ and __ecmp_2.p4__
  * Flowlet Switching: f__lowlet.p4__

### From repositories
* [Very Simple Switch](https://github.com/p4lang/p4c/blob/master/testdata/p4_16_samples/vss-example.p4): __vss.p4__
* [Multicase Replication with NAT](https://github.com/FOXNEOAdvancedTechnology/mc_nat_P4): __mc_nat.p4__
* [Axon Source Routing](https://github.com/p4lang/p4c/blob/master/testdata/p4_14_samples/axon.p4): __axon.p4__


### From publications

* Dapper (asked the authors if they would like to share and if not try to built from the code snippets in the paper): dapper.p4
* [NetPaxos](https://github.com/open-nfpsw/NetPaxos): 
* [DC.p4](https://github.com/p4lang/papers)
* [switch.p4](https://github.com/p4lang/switch/blob/master/p4src/switch.p4) - a data plane description of an L2/L3 switch
* [TimeStamp Aware Switching](https://github.com/FOXNEOAdvancedTechnology/ts_switching_P4): __ts_switching.p4__
* [HashPipe](https://github.com/vibhaa/hashpipe) -  identifying the flows that contribute to majority of packets between two points on a given network: __hashpipe.p4__
* [P4 Linear Road](https://github.com/usi-systems/p4linearroad): __linearroad.p4__
* [NetCache](https://github.com/netx-repo/netcache-p4) - Key-Value store in the data plane to handle queries on hot items and balance load across storage nodes: __netcache.p4__
* [SketchLearn](https://github.com/huangqundl/SketchLearn) - Network measurement framework that resolves resource conflicts by learning their statistical properties to eliminate conflicting traffic components: __sketchlearn.p4__
* [Beamer](https://github.com/Beamer-LB/beamer-p4) - stateless datacenter load balancer and do not store per-connection state: __beamer.p4__
* [NDP Router](https://github.com/nets-cs-pub-ro/NDP): a datacenter router/switch prototype for near-optimal completion times for short transfers: __ndp_router.p4__
* [Sonata](https://github.com/Sonata-Princeton/SONATA-DEV): __sonata.p4__
* [Robust Header Compression](https://github.com/engjefersonsantiago/p4-programs): __rohc.p4__
* [Data plane virtualization with HyperV](https://github.com/HyperVDP/HyperV): __hyperv.p4__
* [P4 Fuzzer](https://github.com/andrei8055/p4-compiler-fuzzer): master thesis work
* [Speedlight](https://github.com/eniac/Speedlight)


## Implementation Analysis

We analyze the surveyed programs in terms of the LoC, the usage of register, counter and meters, whether translated to P4-16.

| Name | LoC | Registers | Counters | Meters | Translated | Notation |
|------|-----|-----------|----------|--------|---|---|
|basic_forward.p4|121|x|x|x|x||
|basic_tunnel.p4|153|x|x|x|x||
|ecn.p4|134|x|x|x|x||
|mri.p4|202|x|x|x|x||
|source_routing.p4|120|x|x|x|x||
|calc.p4|139|x|x|x|x||
|load_balance.p4|178|x|x|x|x||
|ip_forward.p4|122|x|x|x|x||
|arp.p4|228|x|x|x|x||
|hula.p4|289|:white_check_mark:|x|x|x||
|scrambler.p4|134|x|x|x|x||
|heavy_hitter_1.p4|182|x|:white_check_mark:|x|x||
|heavy_hitter_2.p4|178|:white_check_mark:|x|x|x||
|ecmp_1.p4|161|x|x|x|x||
|ecmp_2.p4|157|x|x|x|x||
|flowlet.p4|203|:white_check_mark:|x|x|x||
|vss.p4|130|x|x|x|x||
|mc_nat.p4|131|x|x|x|:white_check_mark:||
|axon.p4|103|x|x|x|x||
|dapper.p4|535|:white_check_mark:|x|x|:white_check_mark:|combined|
|netpaxos_combined.p4|210|:white_check_mark:|x|x|:white_check_mark:|manually generated from acceptor and coordinator|
|DC.p4||x|x|x||barefoot, not v1model, multiple files|
|switch.p4||x|x|x||barefoot, not v1model, multiple files, some includes missing|
|ts_switching-16.p4|133|x|:white_check_mark:|x|:white_check_mark:||
|hashpipe.h4|229|:white_check_mark:|x|x|:white_check_mark:||
|linearroad.p4|789|:white_check_mark:|x|x|:white_check_mark:||
|netcache.p4|1427|:white_check_mark:|x|x|:white_check_mark:|v1model?, multiple files|
|sketchlearn.p4|646|:white_check_mark:|x|x|:white_check_mark:|small modification|
|beamer.p4|310|x|x|x|:white_check_mark:|small modification|
|ndp_router.p4|223|:white_check_mark:|x|x|:white_check_mark:|NetFPGA version also provided|
|rohc.p4|231|x|x|x|x||
|netchain.p4|366|:white_check_mark:|x|x|:white_check_mark:||


### __Note__ ###
* LoC calculation excludes lines of comment and blank lines.
* Programms written in P4_14 are translated into P4_16 by P4C.

## References

References of the publications sorted by the year of publication.

### 2018
* [Life in the Fast Lane: A Line-Rate Linear Road](https://dl.acm.org/citation.cfm?id=3185494)
* [SketchLearn: Relieving User Burdens in Approximate Measurement with Automated Statistical Inference](https://dl.acm.org/citation.cfm?id=3230559)
* [Stateless Datacenter Load-balancing with Beamer](https://www.usenix.org/conference/nsdi18/presentation/olteanu)
* [Extern Objects in P4: an ROHC Compression Case Study](https://arxiv.org/abs/1611.05943)
* [Synchronized Network Snapshots](https://dl.acm.org/citation.cfm?id=3230552)
* [NetChain: Scale-Free Sub-RTT Coordination](https://www.usenix.org/conference/nsdi18/presentation/jin)
### 2017
* [Dapper: Data Plane Performance Diagnosis of TCP](https://dl.acm.org/citation.cfm?id=3050228)
* [Heavy-Hitter Detection Entirely in the Data Plane](https://dl.acm.org/citation.cfm?id=3063772)
* [NetCache: Balancing Key-Value Stores with Fast In-Network Caching](https://dl.acm.org/citation.cfm?id=3132747.3132764)
* [Re-architecting datacenter networks and stacks for low latency and high performance](https://dl.acm.org/citation.cfm?id=3098825)
* [HyperV: High-Performance Virtualization of the Programmable Data Plane](https://ieeexplore.ieee.org/abstract/document/8038396/)
* [Dapper: Data Plane Performance Diagnosis of TCP](https://dl.acm.org/citation.cfm?id=3050228)
### 2016
* [Paxos Made Switch-y](https://dl.acm.org/citation.cfm?doid=2935634.2935638)
* [Timestamp-Aware RTP Video	Switching Using	Programmable Data Plane](https://conferences.sigcomm.org/sigcomm/2017/files/program-industrial-demos/sigcomm17industrialdemos-paper2.pdf)
### 2015
* [DC.p4: Programming the forwarding plane of a data-center switch](https://dl.acm.org/citation.cfm?id=2775007)








