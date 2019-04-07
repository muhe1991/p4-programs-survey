#define INST_SIZE 32
#define PROPOSAL_SIZE 16
#define VALUE_SIZE 32
#define ACPT_SIZE 16
#define MSGTYPE_SIZE 16
#define INST_COUNT 64000

#define PHASE_1A 1
#define PHASE_1B 2
#define PHASE_2A 3
#define PHASE_2B 4

header_type ethernet_t {
    fields {
        dstAddr : 48;
        srcAddr : 48;
        etherType : 16;
    }
}

header_type ipv4_t {
    fields {
        version : 4;
        ihl : 4;
        diffserv : 8;
        totalLen : 16;
        identification : 16;
        flags : 3;
        fragOffset : 13;
        ttl : 8;
        protocol : 8;
        hdrChecksum : 16;
        src : 32;
        dst: 32;
    }
}

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        length_ : 16;
        checksum : 16;
    }
}

// Headers for Paxos

header_type paxos_t {
    fields {
        inst      : INST_SIZE;
        proposal  : PROPOSAL_SIZE;
        vproposal : PROPOSAL_SIZE;
        acpt      : ACPT_SIZE;
        msgtype   : MSGTYPE_SIZE;
        val       : VALUE_SIZE;
        fsh       : 32;  // Forwarding start (h: high bits, l: low bits)
        fsl       : 32;
        feh       : 32;  // Forwarding end
        fel       : 32;
        csh       : 32;  // Coordinator start
        csl       : 32;
        ceh       : 32;  // Coordinator end
        cel       : 32;
        ash       : 32;  // Acceptor start
        asl       : 32;
        aeh       : 32; // Acceptor end
        ael       : 32;
    }
}

header_type local_metadata_t {
    fields {
        inst : INST_SIZE;
    }
}


header ethernet_t ethernet;
header ipv4_t ipv4;
header udp_t udp;
header paxos_t paxos;
metadata local_metadata_t local_metadata;

#define ETHERTYPE_IPV4 0x0800
#define UDP_PROTOCOL 0x11
#define PAXOS_PROTOCOL 0x8888

parser start {
    return parse_ethernet;
}

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4; 
        default : ingress;
    }
}

parser parse_ipv4 {
    extract(ipv4);
    return select(latest.protocol) {
        UDP_PROTOCOL : parse_udp;
        default : ingress;
    }
}

parser parse_udp {
    extract(udp);
    return select(udp.dstPort) {
        PAXOS_PROTOCOL: parse_paxos;
        default: ingress;
    }
}

parser parse_paxos {
    extract(paxos);
    return ingress;
}

register inst_register {
    width : INST_SIZE;
    instance_count : INST_COUNT;
}


// primitive_action get_forwarding_start_time();
// primitive_action get_forwarding_end_time();
// primitive_action get_coordinator_start_time();
// primitive_action get_coordinator_end_time();


action forward(port) {
    // get_forwarding_start_time();
    _no_op();
    modify_field(standard_metadata.egress_spec, port);
    // get_forwarding_end_time();
    _no_op();
}

table fwd_tbl {
    reads {
        standard_metadata.ingress_port : exact;
    }
    actions {
        forward;
        _drop;
    }
    size : 8;
}

action _no_op() {
}

action _drop() {
    drop();
}

action increase_sequence() {
    // get_coordinator_start_time();
    _no_op();
    register_read(local_metadata.inst, inst_register, 0);
    modify_field(paxos.inst, local_metadata.inst);
    modify_field(local_metadata.inst, local_metadata.inst + 1);
    register_write(inst_register, 0, local_metadata.inst);
    modify_field(paxos.msgtype, PHASE_2A);
    modify_field(udp.checksum, 0);
    // get_coordinator_end_time();
    _no_op();
}

action reset_paxos() {
    modify_field(local_metadata.inst, 0);
    register_write(inst_register, 0, local_metadata.inst);
}

table paxos_tbl {
    reads {
        paxos.msgtype : exact;
    }
    actions {
        increase_sequence;
        reset_paxos;
        _no_op;
    }
    size : 8;
}

control ingress {
    if (valid (ipv4)) {
        apply(fwd_tbl);
    }
    if (valid (paxos)) {
        apply(paxos_tbl);
    }
}