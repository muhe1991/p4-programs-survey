#include "headers.p4"

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


primitive_action get_forwarding_start_time();
primitive_action get_forwarding_end_time();
primitive_action get_coordinator_start_time();
primitive_action get_coordinator_end_time();


action forward(port) {
    get_forwarding_start_time();
    modify_field(standard_metadata.egress_spec, port);
    get_forwarding_end_time();
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
    get_coordinator_start_time();
    register_read(local_metadata.inst, inst_register, 0);
    modify_field(paxos.inst, local_metadata.inst);
    modify_field(local_metadata.inst, local_metadata.inst + 1);
    register_write(inst_register, 0, local_metadata.inst);
    modify_field(paxos.msgtype, PHASE_2A);
    modify_field(udp.checksum, 0);
    get_coordinator_end_time();
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