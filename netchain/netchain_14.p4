#define SEQUENCE_REG_SIZE   4096
#define VALUE_REG_SIZE  4096

#define NUM_CACHE   128
#define NC_PORT 8888
#define REPLY_PORT  8889
#define NC_READ_REQUEST 10
#define NC_READ_REPLY   11
#define NC_WRITE_REQUEST    12
#define NC_WRITE_REPLY  13
#define DROP_PORT   9999
#define END_OF_CHAIN    0
#define MAX_LENGTH_OF_CHAIN 10
#define HEAD_NODE   100
#define REPLICA_NODE    101
#define TAIL_NODE   102
#define DROPPED 100

header_type ethernet_t {
    fields {
        dstAddr : 48;
        srcAddr : 48;
        etherType : 16;
    }
}
header ethernet_t ethernet;

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
header ipv4_t ipv4;

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
header tcp_t tcp;

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        len : 16;
        checksum : 16;
    }
}
header udp_t udp;

header_type overlay_t {
    fields {
        swip: 32;
    }
}
header overlay_t overlay [MAX_LENGTH_OF_CHAIN];

header_type nc_hdr_t {
    fields {
        op: 8;
        sc: 8;
        seq: 16;
        key: 128;
        value: 128;
        vgroup: 16;
    }

}
header nc_hdr_t nc_hdr;

parser start {
    return parse_ethernet;
}

#define ETHER_TYPE_IPV4 0x0800
parser parse_ethernet {
    extract (ethernet);
    return select (latest.etherType) {
        ETHER_TYPE_IPV4: parse_ipv4;
        default: ingress;
    }
}

#define IPV4_PROTOCOL_TCP 6
#define IPV4_PROTOCOL_UDP 17
parser parse_ipv4 {
    extract(ipv4);
    return select (latest.protocol) {
        IPV4_PROTOCOL_TCP: parse_tcp;
        IPV4_PROTOCOL_UDP: parse_udp;
        default: ingress;
    }
}

parser parse_tcp {
    extract (tcp);
    return ingress;
}

parser parse_udp {
    extract (udp);
    return select (latest.dstPort) {
        NC_PORT: parse_overlay;
        REPLY_PORT: parse_overlay;
        default: ingress;
    }
}

parser parse_overlay {
    extract (overlay[next]);
    return select (latest.swip) {
        END_OF_CHAIN: parse_nc_hdr;
        default: parse_overlay;
    }
}

parser parse_nc_hdr {
    extract (nc_hdr);
    return select(latest.op) {
        NC_READ_REQUEST: ingress;
        NC_WRITE_REQUEST: ingress;
        default: ingress;
    }
}

field_list ipv4_field_list {
    ipv4.version;
    ipv4.ihl;
    ipv4.diffserv;
    ipv4.totalLen;
    ipv4.identification;
    ipv4.flags;
    ipv4.fragOffset;
    ipv4.ttl;
    ipv4.protocol;
    ipv4.srcAddr;
    ipv4.dstAddr;
}
field_list_calculation ipv4_chksum_calc {
    input {
        ipv4_field_list;
    }
    algorithm : csum16;
    output_width: 16;
}
calculated_field ipv4.hdrChecksum {
    update ipv4_chksum_calc;
}

field_list udp_checksum_list {
    // IPv4 Pseudo Header Format. Must modify for IPv6 support.
    ipv4.srcAddr;
    ipv4.dstAddr;
    8'0;
    ipv4.protocol;
    udp.len;
    udp.srcPort;
    udp.dstPort;
    udp.len;
    // udp.checksum;
    payload;
}
field_list_calculation udp_checksum {
    input {
        udp_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}
calculated_field udp.checksum {
    update udp_checksum;
}

action set_egress(egress_spec) {
    modify_field(standard_metadata.egress_spec, egress_spec);
    add_to_field(ipv4.ttl, -1);
}

@pragma stage 11
table ipv4_route {
    reads {
        ipv4.dstAddr : exact;
    }
    actions {
        set_egress;
    }
    size : 8192;
}

action ethernet_set_mac_act (smac, dmac) {
    modify_field (ethernet.srcAddr, smac);
    modify_field (ethernet.dstAddr, dmac);
}
table ethernet_set_mac {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        ethernet_set_mac_act;
    }
}


register sequence_reg {
    width: 16;
    instance_count: SEQUENCE_REG_SIZE;
}

register value_reg {
    width: 128;
    instance_count: VALUE_REG_SIZE;
}


header_type location_t {
    fields {
        index: 16;
    }
}
metadata location_t location;

header_type sequence_md_t {
    fields {
        seq: 16;
        tmp: 16;
    }
}
metadata sequence_md_t sequence_md;

header_type my_md_t {
    fields {
        ipaddress: 32;
        role: 16;
        failed: 16;
    }
}
metadata my_md_t my_md;

header_type reply_addr_t {
    fields {
        ipv4_srcAddr: 32;
        ipv4_dstAddr: 32;
    }
}
metadata reply_addr_t reply_to_client_md;

field_list rec_fl {
    standard_metadata;
    location;
    sequence_md;
    my_md;
    reply_to_client_md;
}


action find_index_act(index) {
    modify_field(location.index, index);
}

table find_index {
    reads {
        nc_hdr.key: exact;
    }
    actions {
        find_index_act;
    }
}


action get_sequence_act() {
    register_read(sequence_md.seq, sequence_reg, location.index);
}

table get_sequence {
    actions {
        get_sequence_act;
    }
}

action maintain_sequence_act() {
    add_to_field(sequence_md.seq, 1);
    register_write(sequence_reg, location.index, sequence_md.seq);
    register_read(nc_hdr.seq, sequence_reg, location.index);
}

table maintain_sequence {
    actions {
        maintain_sequence_act;
    }
}

action read_value_act() {
    register_read (nc_hdr.value, value_reg, location.index);
}

table read_value {
    actions {
        read_value_act;
    }
}

action assign_value_act() {
    register_write(sequence_reg, location.index, nc_hdr.seq);
    register_write(value_reg, location.index, nc_hdr.value);
}

table assign_value {
    actions {
        assign_value_act;
    }
}

action pop_chain_act() {
    add_to_field(nc_hdr.sc, -1);
    pop(overlay, 1);
    add_to_field(udp.len, -4);
    add_to_field(ipv4.totalLen, -4);
}

table pop_chain {
    actions {
        pop_chain_act;
    }
}

table pop_chain_again {
    actions {
        pop_chain_act;
    }
}

action gen_reply_act(message_type) {
    modify_field(reply_to_client_md.ipv4_srcAddr, ipv4.dstAddr);
    modify_field(reply_to_client_md.ipv4_dstAddr, ipv4.srcAddr);
    modify_field(ipv4.srcAddr, reply_to_client_md.ipv4_srcAddr);
    modify_field(ipv4.dstAddr, reply_to_client_md.ipv4_dstAddr);
    modify_field(nc_hdr.op, message_type);
    modify_field(udp.dstPort, REPLY_PORT);
}

table gen_reply {
    reads {
        nc_hdr.op: exact;
    }
    actions {
        gen_reply_act;
    }
}

action drop_packet_act() {
    drop();
}

table drop_packet {
    actions {
        drop_packet_act;
    }
}

action get_my_address_act(sw_ip, sw_role) {
    modify_field(my_md.ipaddress, sw_ip);
    modify_field(my_md.role, sw_role);
}

table get_my_address {
    reads {
        nc_hdr.key: exact;
    }
    actions {
        get_my_address_act;
    }
}

action get_next_hop_act() {
    modify_field(ipv4.dstAddr, overlay[0].swip);
}

table get_next_hop {
    actions {
        get_next_hop_act;
    }
}

action failover_act() {
    modify_field(ipv4.dstAddr, overlay[1].swip);
    pop_chain_act();
}

action failover_write_reply_act() {
    gen_reply_act(NC_WRITE_REPLY);
}

action failure_recovery_act(nexthop) {
    modify_field(overlay[0].swip, nexthop);
    modify_field(ipv4.dstAddr, nexthop);
}

action nop() {
    no_op();
}

table failure_recovery {
    reads {
        ipv4.dstAddr: ternary;
        overlay[1].swip: ternary;
        nc_hdr.vgroup: ternary;
    }
    actions {
        failover_act;
        failover_write_reply_act;
        failure_recovery_act;
        nop;
        drop_packet_act;
    }
}

control ingress {
    if (valid(nc_hdr)) {
        apply (get_my_address);
        if (ipv4.dstAddr == my_md.ipaddress) {
            apply (find_index);
            apply (get_sequence);
            if (nc_hdr.op == NC_READ_REQUEST) {
                apply (read_value);
            }
            else if (nc_hdr.op == NC_WRITE_REQUEST) {
                if (my_md.role == HEAD_NODE) {
                    apply (maintain_sequence);
                }
                if ((my_md.role == HEAD_NODE) or (nc_hdr.seq > sequence_md.seq)) {
                    apply (assign_value);
                    apply (pop_chain);
                }
                else {
                    apply (drop_packet);
                }

            }
            if (my_md.role == TAIL_NODE) {
                apply (pop_chain_again);
                apply (gen_reply);
            }
            else {
                apply (get_next_hop);
            }
        }
    }
    if (valid(nc_hdr)) {
        apply (failure_recovery);
        
    }
    if (valid(tcp) or valid(udp)) {
        apply (ipv4_route);
    }
}

control egress {
    apply (ethernet_set_mac);
}

