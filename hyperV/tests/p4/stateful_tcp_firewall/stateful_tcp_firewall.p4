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
        srcAddr : 32;
        dstAddr: 32;
    }
}

header_type tcp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        seqNo : 32;
        ackNo : 32;
        dataOffset : 4;
        res : 3;
        ecn : 3;
        ctrl : 6;
        window : 16;
        checksum : 16;
        urgentPtr : 16;
    }
}

#define ETHERTYPE_IPV4     0x0800

#define IP_PROTOCOLS_TCP   0x06

header ethernet_t ethernet;
header ipv4_t ipv4;
header tcp_t tcp;
metadata state_metadata_t state_metadata;

parser start {
    return parse_ethernet;
}

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;                      
        default: ingress;
    }
}

parser parse_ipv4 {
    extract(ipv4);
    return select(latest.protocol) {
        IP_PROTOCOLS_TCP : parse_tcp;
        default: ingress;
    }
}

parser parse_tcp {
    extract(tcp);
    return ingress;
}

header_type state_metadata_t {
    fields {
        cur_state   : 8;
        next_state  : 8;
        trigger     : 16;   
    }
}

register state_register {
   width : 8;
   instance_count : 1024;
}

action alert() {
    drop();
}

action forward(port) {
    modify_field(standard_metadata.egress_spec, port);
}

action get_state_with_tcp_flag(register_id) {
    register_read(state_metadata.cur_state, state_register, register_id);
    modify_field(state_metadata.trigger, tcp.ctrl);
}

action state_transfer(next_state, register_id) {
    register_write(state_register, register_id, next_state);
    modify_field(state_metadata.next_state, next_state);
}

table forward_table {
    reads {
        standard_metadata.ingress_port : exact;
    }
    actions {
        forward;
    }
}

table state_table {
    reads {
        ipv4.dstAddr : exact;
        ipv4.srcAddr : exact;
        tcp.srcPort  : exact;
        tcp.dstPort  : exact;
    }
    actions {
        get_state_with_tcp_flag;
    }
}

table state_transfer_table {
    reads {
        state_metadata.cur_state : exact;
        state_metadata.trigger   : exact;
    }
    actions {
        state_transfer;
    }
}

action noop() {

}

table action_table {
    reads {
        state_metadata.next_state : exact;
    }
    actions {
        noop;
        alert;
    }
}

control ingress {
    apply(forward_table);
    if (valid(tcp)) {
        apply(state_table) {
            hit {
                apply(state_transfer_table);
            }
        }
        apply(action_table);
    }
}
