#include "headers.p4"

header_type local_metadata_t {
    fields {
        proposal : PROPOSAL_SIZE;
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

register acceptor_id {
    width: ACPT_SIZE;
    instance_count : 1; 
}

register proposal_register {
    width : PROPOSAL_SIZE;
    instance_count : INST_COUNT;
}

register vproposal_register {
    width : PROPOSAL_SIZE;
    instance_count : INST_COUNT;
}

register val_register {
    width : VALUE_SIZE;
    instance_count : INST_COUNT;
}

primitive_action get_forwarding_start_time();
primitive_action get_forwarding_end_time();
primitive_action get_acceptor_start_time();
primitive_action get_acceptor_end_time();


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

action read_round() {
    register_read(local_metadata.proposal, proposal_register, paxos.inst); 
}

table round_tbl {
    actions { read_round; }
    size : 1;
}


action handle_phase1a() {
    get_acceptor_start_time();
    register_write(proposal_register, paxos.inst, paxos.proposal);
    register_read(paxos.vproposal, vproposal_register, paxos.inst);
    register_read(paxos.val, val_register, paxos.inst);
    modify_field(paxos.msgtype, PHASE_1B);
    register_read(paxos.acpt, acceptor_id, 0);
    modify_field(udp.checksum, 0);
    get_acceptor_end_time();
}

action handle_phase2a() {
    get_acceptor_start_time();
    register_write(proposal_register, paxos.inst, paxos.proposal);
    register_write(vproposal_register, paxos.inst, paxos.proposal);
    register_write(val_register, paxos.inst, paxos.val);
    modify_field(paxos.msgtype, PHASE_2B);
    modify_field(paxos.vproposal, paxos.proposal);
    register_read(paxos.acpt, acceptor_id, 0);
    modify_field(udp.checksum, 0);
    get_acceptor_end_time();
}

table paxos_tbl {
    reads {
        paxos.msgtype : exact;
    }
    actions {
        handle_phase1a;
        handle_phase2a;
        _no_op;
    }
    size : 8;
}

table drop_tbl {
    actions {
        _drop;
    }
    size : 1;
}

control ingress {
    if (valid (ipv4)) {
        apply(fwd_tbl);
    }

    if (valid (paxos)) {
        apply(round_tbl);
        if (local_metadata.proposal <= paxos.proposal) {
            apply(paxos_tbl);
        } else {
            apply(drop_tbl);
        }
    }

}