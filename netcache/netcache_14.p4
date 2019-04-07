#define NC_PORT 8888

#define NUM_CACHE 128

#define NC_READ_REQUEST     0
#define NC_READ_REPLY       1
#define NC_HOT_READ_REQUEST 2
#define NC_WRITE_REQUEST    4
#define NC_WRITE_REPLY      5
#define NC_UPDATE_REQUEST   8
#define NC_UPDATE_REPLY     9

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

header_type nc_hdr_t {
    fields {
        op: 8;
        key: 128;
    }
}
header nc_hdr_t nc_hdr;

header_type nc_load_t {
    fields {
        load_1: 32;
        load_2: 32;
        load_3: 32;
        load_4: 32;
    }
}
header nc_load_t nc_load;

/*
    The headers for value are defined in value.p4
    k = 1, 2, ..., 8
    header_type nc_value_{k}_t {
        fields {
            value_{k}_1: 32;
            value_{k}_2: 32;
            value_{k}_3: 32;
            value_{k}_4: 32;
        }
    }
*/

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
        NC_PORT: parse_nc_hdr;
        default: ingress;
    }
}

parser parse_nc_hdr {
    extract (nc_hdr);
    return select(latest.op) {
        NC_READ_REQUEST: ingress;
        NC_READ_REPLY: parse_value;
        NC_HOT_READ_REQUEST: parse_nc_load;
        NC_UPDATE_REQUEST: ingress;
        NC_UPDATE_REPLY: parse_value;
        default: ingress;
    }
}

parser parse_nc_load {
    extract (nc_load);
    return ingress;
}

parser parse_value {
    return parse_nc_value_1;
}

/*
    The parsers for value headers are defined in value.p4
    k = 1, 2, ..., 8
    parser parse_value_{k} {
        extract (nc_value_{k});
        return select(k) {
            8: ingress;
            default: parse_value_{k + 1};
        }
    }
*/

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

header_type nc_cache_md_t {
    fields {
        cache_exist: 1;
        cache_index: 14;
        cache_valid: 1;
    }
}
metadata nc_cache_md_t nc_cache_md;


action check_cache_exist_act(index) {
    modify_field (nc_cache_md.cache_exist, 1);
    modify_field (nc_cache_md.cache_index, index);
}
table check_cache_exist {
    reads {
        nc_hdr.key: exact;
    }
    actions {
        check_cache_exist_act;
    }
    size: NUM_CACHE;
}


register cache_valid_reg {
    width: 1;
    instance_count: NUM_CACHE;
}

action check_cache_valid_act() {
    register_read(nc_cache_md.cache_valid, cache_valid_reg, nc_cache_md.cache_index);
}
table check_cache_valid {
    actions {
        check_cache_valid_act;
    }
    //default_action: check_cache_valid_act;
}

action set_cache_valid_act() {
    register_write(cache_valid_reg, nc_cache_md.cache_index, 1);
}
table set_cache_valid {
    actions {
        set_cache_valid_act;
    }
    //default_action: set_cache_valid_act;
}

control process_cache {
    apply (check_cache_exist);
    if (nc_cache_md.cache_exist == 1) {
        if (nc_hdr.op == NC_READ_REQUEST) {
            apply (check_cache_valid);
        }
        else if (nc_hdr.op == NC_UPDATE_REPLY) {
            apply (set_cache_valid);
        }
    }
}

#define HH_LOAD_WIDTH       32
#define HH_LOAD_NUM         256
#define HH_LOAD_HASH_WIDTH  8
#define HH_THRESHOLD        128
#define HH_BF_NUM           512
#define HH_BF_HASH_WIDTH    9

header_type nc_load_md_t {
    fields {
        index_1: 16;
        index_2: 16;
        index_3: 16;
        index_4: 16;
        
        load_1: 32;
        load_2: 32;
        load_3: 32;
        load_4: 32;
    }
}
metadata nc_load_md_t nc_load_md;

field_list hh_hash_fields {
    nc_hdr.key;
}

register hh_load_1_reg {
    width: HH_LOAD_WIDTH;
    instance_count: HH_LOAD_NUM;
}
field_list_calculation hh_load_1_hash {
    input {
        hh_hash_fields;
    }
    algorithm : crc32;
    output_width : HH_LOAD_HASH_WIDTH;
}
action hh_load_1_count_act() {
    modify_field_with_hash_based_offset(nc_load_md.index_1, 0, hh_load_1_hash, HH_LOAD_NUM);
    register_read(nc_load_md.load_1, hh_load_1_reg, nc_load_md.index_1);
    register_write(hh_load_1_reg, nc_load_md.index_1, nc_load_md.load_1 + 1);
}
table hh_load_1_count {
    actions {
        hh_load_1_count_act;
    }
}

register hh_load_2_reg {
    width: HH_LOAD_WIDTH;
    instance_count: HH_LOAD_NUM;
}
field_list_calculation hh_load_2_hash {
    input {
        hh_hash_fields;
    }
    algorithm : csum16;
    output_width : HH_LOAD_HASH_WIDTH;
}
action hh_load_2_count_act() {
    modify_field_with_hash_based_offset(nc_load_md.index_2, 0, hh_load_2_hash, HH_LOAD_NUM);
    register_read(nc_load_md.load_2, hh_load_2_reg, nc_load_md.index_2);
    register_write(hh_load_2_reg, nc_load_md.index_2, nc_load_md.load_2 + 1);
}
table hh_load_2_count {
    actions {
        hh_load_2_count_act;
    }
}

register hh_load_3_reg {
    width: HH_LOAD_WIDTH;
    instance_count: HH_LOAD_NUM;
}
field_list_calculation hh_load_3_hash {
    input {
        hh_hash_fields;
    }
    algorithm : crc16;
    output_width : HH_LOAD_HASH_WIDTH;
}
action hh_load_3_count_act() {
    modify_field_with_hash_based_offset(nc_load_md.index_3, 0, hh_load_3_hash, HH_LOAD_NUM);
    register_read(nc_load_md.load_3, hh_load_3_reg, nc_load_md.index_3);
    register_write(hh_load_3_reg, nc_load_md.index_3, nc_load_md.load_3 + 1);
}
table hh_load_3_count {
    actions {
        hh_load_3_count_act;
    }
}

register hh_load_4_reg {
    width: HH_LOAD_WIDTH;
    instance_count: HH_LOAD_NUM;
}
field_list_calculation hh_load_4_hash {
    input {
        hh_hash_fields;
    }
    algorithm : crc32;
    output_width : HH_LOAD_HASH_WIDTH;
}
action hh_load_4_count_act() {
    modify_field_with_hash_based_offset(nc_load_md.index_4, 0, hh_load_4_hash, HH_LOAD_NUM);
    register_read(nc_load_md.load_4, hh_load_4_reg, nc_load_md.index_4);
    register_write(hh_load_4_reg, nc_load_md.index_4, nc_load_md.load_4 + 1);
}
table hh_load_4_count {
    actions {
        hh_load_4_count_act;
    }
}

control count_min {
    apply (hh_load_1_count);
    apply (hh_load_2_count);
    apply (hh_load_3_count);
    apply (hh_load_4_count);
}

header_type hh_bf_md_t {
    fields {
        index_1: 16;
        index_2: 16;
        index_3: 16;
    
        bf_1: 1;
        bf_2: 1;
        bf_3: 1;
    }
}
metadata hh_bf_md_t hh_bf_md;

register hh_bf_1_reg {
    width: 1;
    instance_count: HH_BF_NUM;
}
field_list_calculation hh_bf_1_hash {
    input {
        hh_hash_fields;
    }
    algorithm : crc32;
    output_width : HH_BF_HASH_WIDTH;
}
action hh_bf_1_act() {
    modify_field_with_hash_based_offset(hh_bf_md.index_1, 0, hh_bf_1_hash, HH_BF_NUM);
    register_read(hh_bf_md.bf_1, hh_bf_1_reg, hh_bf_md.index_1);
    register_write(hh_bf_1_reg, hh_bf_md.index_1, 1);
}
table hh_bf_1 {
    actions {
        hh_bf_1_act;
    }
}

register hh_bf_2_reg {
    width: 1;
    instance_count: HH_BF_NUM;
}
field_list_calculation hh_bf_2_hash {
    input {
        hh_hash_fields;
    }
    algorithm : csum16;
    output_width : HH_BF_HASH_WIDTH;
}
action hh_bf_2_act() {
    modify_field_with_hash_based_offset(hh_bf_md.index_2, 0, hh_bf_2_hash, HH_BF_NUM);
    register_read(hh_bf_md.bf_2, hh_bf_2_reg, hh_bf_md.index_2);
    register_write(hh_bf_2_reg, hh_bf_md.index_2, 1);
}
table hh_bf_2 {
    actions {
        hh_bf_2_act;
    }
}

register hh_bf_3_reg {
    width: 1;
    instance_count: HH_BF_NUM;
}
field_list_calculation hh_bf_3_hash {
    input {
        hh_hash_fields;
    }
    algorithm : crc16;
    output_width : HH_BF_HASH_WIDTH;
}
action hh_bf_3_act() {
    modify_field_with_hash_based_offset(hh_bf_md.index_3, 0, hh_bf_3_hash, HH_BF_NUM);
    register_read(hh_bf_md.bf_3, hh_bf_3_reg, hh_bf_md.index_3);
    register_write(hh_bf_3_reg, hh_bf_md.index_3, 1);
}
table hh_bf_3 {
    actions {
        hh_bf_3_act;
    }
}

control bloom_filter {
    apply (hh_bf_1);
    apply (hh_bf_2);
    apply (hh_bf_3);
}

field_list mirror_list {
    nc_load_md.load_1;
    nc_load_md.load_2;
    nc_load_md.load_3;
    nc_load_md.load_4;
}

#define CONTROLLER_MIRROR_DSET 3
action clone_to_controller_act() {
    clone_egress_pkt_to_egress(CONTROLLER_MIRROR_DSET, mirror_list);
}

table clone_to_controller {
    actions {
        clone_to_controller_act;
    }
}

control report_hot_step_1 {
    apply (clone_to_controller);
}

#define CONTROLLER_IP 0x0a000003
action report_hot_act() {
    modify_field (nc_hdr.op, NC_HOT_READ_REQUEST);
    
    add_header (nc_load);
    add_to_field(ipv4.totalLen, 16);
    add_to_field(udp.len, 16);
    modify_field (nc_load.load_1, nc_load_md.load_1);
    modify_field (nc_load.load_2, nc_load_md.load_2);
    modify_field (nc_load.load_3, nc_load_md.load_3);
    modify_field (nc_load.load_4, nc_load_md.load_4);
    
    modify_field (ipv4.dstAddr, CONTROLLER_IP);
}

table report_hot {
    actions {
        report_hot_act;
    }
}

control report_hot_step_2 {
    apply (report_hot);
}   

control heavy_hitter {
    if (standard_metadata.instance_type == 0) {
        count_min();
        if (nc_load_md.load_1 > HH_THRESHOLD) {
            if (nc_load_md.load_2 > HH_THRESHOLD) {
                if (nc_load_md.load_3 > HH_THRESHOLD) {
                    if (nc_load_md.load_4 > HH_THRESHOLD) {
                        bloom_filter();
                        if (hh_bf_md.bf_1 == 0 or hh_bf_md.bf_2 == 0 or hh_bf_md.bf_3 == 0){
                            report_hot_step_1();
                        }
                    }
                }
            }
        }
    }
    else {
        report_hot_step_2();
    }
}

#define HEADER_VALUE(i) \
    header_type nc_value_##i##_t { \
        fields { \
            value_##i##_1: 32; \
            value_##i##_2: 32; \
            value_##i##_3: 32; \
            value_##i##_4: 32; \
        } \
    } \
    header nc_value_##i##_t nc_value_##i;

#define PARSER_VALUE(i, ip1) \
    parser parse_nc_value_##i { \
        extract (nc_value_##i); \
        return parse_nc_value_##ip1; \
    }

#define REGISTER_VALUE_SLICE(i, j) \
    register value_##i##_##j##_reg { \
        width: 32; \
        instance_count: NUM_CACHE; \
    }

#define REGISTER_VALUE(i) \
    REGISTER_VALUE_SLICE(i, 1) \
    REGISTER_VALUE_SLICE(i, 2) \
    REGISTER_VALUE_SLICE(i, 3) \
    REGISTER_VALUE_SLICE(i, 4) 

#define ACTION_READ_VALUE_SLICE(i, j) \
    action read_value_##i##_##j##_act() { \
        register_read(nc_value_##i.value_##i##_##j, value_##i##_##j##_reg, nc_cache_md.cache_index); \
    }

#define ACTION_READ_VALUE(i) \
    ACTION_READ_VALUE_SLICE(i, 1) \
    ACTION_READ_VALUE_SLICE(i, 2) \
    ACTION_READ_VALUE_SLICE(i, 3) \
    ACTION_READ_VALUE_SLICE(i, 4)

#define TABLE_READ_VALUE_SLICE(i, j) \
    table read_value_##i##_##j { \
        actions { \
            read_value_##i##_##j##_act; \
        } \
    }

#define TABLE_READ_VALUE(i) \
    TABLE_READ_VALUE_SLICE(i, 1) \
    TABLE_READ_VALUE_SLICE(i, 2) \
    TABLE_READ_VALUE_SLICE(i, 3) \
    TABLE_READ_VALUE_SLICE(i, 4)

#define ACTION_ADD_VALUE_HEADER(i) \
    action add_value_header_##i##_act() { \
        add_to_field(ipv4.totalLen, 16);\
        add_to_field(udp.len, 16);\
        add_header(nc_value_##i); \
    }

#define TABLE_ADD_VALUE_HEADER(i) \
    table add_value_header_##i { \
        actions { \
            add_value_header_##i##_act; \
        } \
    }

#define ACTION_WRITE_VALUE_SLICE(i, j) \
    action write_value_##i##_##j##_act() { \
        register_write(value_##i##_##j##_reg, nc_cache_md.cache_index, nc_value_##i.value_##i##_##j); \
    }

#define ACTION_WRITE_VALUE(i) \
    ACTION_WRITE_VALUE_SLICE(i, 1) \
    ACTION_WRITE_VALUE_SLICE(i, 2) \
    ACTION_WRITE_VALUE_SLICE(i, 3) \
    ACTION_WRITE_VALUE_SLICE(i, 4)

#define TABLE_WRITE_VALUE_SLICE(i, j) \
    table write_value_##i##_##j { \
        actions { \
            write_value_##i##_##j##_act; \
        } \
    }

#define TABLE_WRITE_VALUE(i) \
    TABLE_WRITE_VALUE_SLICE(i, 1) \
    TABLE_WRITE_VALUE_SLICE(i, 2) \
    TABLE_WRITE_VALUE_SLICE(i, 3) \
    TABLE_WRITE_VALUE_SLICE(i, 4)

#define ACTION_REMOVE_VALUE_HEADER(i) \
    action remove_value_header_##i##_act() { \
        subtract_from_field(ipv4.totalLen, 16);\
        subtract_from_field(udp.len, 16);\
        remove_header(nc_value_##i); \
    }

#define TABLE_REMOVE_VALUE_HEADER(i) \
    table remove_value_header_##i { \
        actions { \
            remove_value_header_##i##_act; \
        } \
    }

#define CONTROL_PROCESS_VALUE(i) \
    control process_value_##i { \
        if (nc_hdr.op == NC_READ_REQUEST and nc_cache_md.cache_valid == 1) { \
            apply (add_value_header_##i); \
            apply (read_value_##i##_1); \
            apply (read_value_##i##_2); \
            apply (read_value_##i##_3); \
            apply (read_value_##i##_4); \
        } \
        else if (nc_hdr.op == NC_UPDATE_REPLY and nc_cache_md.cache_exist == 1) { \
            apply (write_value_##i##_1); \
            apply (write_value_##i##_2); \
            apply (write_value_##i##_3); \
            apply (write_value_##i##_4); \
            apply (remove_value_header_##i); \
        } \
    }

#define HANDLE_VALUE(i, ip1) \
    HEADER_VALUE(i) \
    PARSER_VALUE(i, ip1) \
    REGISTER_VALUE(i) \
    ACTION_READ_VALUE(i) \
    TABLE_READ_VALUE(i) \
    ACTION_ADD_VALUE_HEADER(i) \
    TABLE_ADD_VALUE_HEADER(i) \
    ACTION_WRITE_VALUE(i) \
    TABLE_WRITE_VALUE(i) \
    ACTION_REMOVE_VALUE_HEADER(i) \
    TABLE_REMOVE_VALUE_HEADER(i) \
    CONTROL_PROCESS_VALUE(i)

#define FINAL_PARSER(i) \
    parser parse_nc_value_##i { \
        return ingress; \
    }

HANDLE_VALUE(1, 2)
HANDLE_VALUE(2, 3)
HANDLE_VALUE(3, 4)
HANDLE_VALUE(4, 5)
HANDLE_VALUE(5, 6)
HANDLE_VALUE(6, 7)
HANDLE_VALUE(7, 8)
HANDLE_VALUE(8, 9)
FINAL_PARSER(9)

header_type reply_read_hit_info_md_t {
    fields {
        ipv4_srcAddr: 32;
        ipv4_dstAddr: 32;
    }
}

metadata reply_read_hit_info_md_t reply_read_hit_info_md;

action reply_read_hit_before_act() {
    modify_field (reply_read_hit_info_md.ipv4_srcAddr, ipv4.srcAddr);
    modify_field (reply_read_hit_info_md.ipv4_dstAddr, ipv4.dstAddr);
}

table reply_read_hit_before {
    actions {
        reply_read_hit_before_act;
    }
}

action reply_read_hit_after_act() {
    modify_field (ipv4.srcAddr, reply_read_hit_info_md.ipv4_dstAddr);
    modify_field (ipv4.dstAddr, reply_read_hit_info_md.ipv4_srcAddr);
    modify_field (nc_hdr.op, NC_READ_REPLY);
}

table reply_read_hit_after {
    actions {
        reply_read_hit_after_act;
    }
}

control process_value {    
    if (nc_hdr.op == NC_READ_REQUEST and nc_cache_md.cache_valid == 1) {
        apply (reply_read_hit_before);
    }
    process_value_1();
    process_value_2();
    process_value_3();
    process_value_4();
    process_value_5();
    process_value_6();
    process_value_7();
    process_value_8();
    if (nc_hdr.op == NC_READ_REQUEST and nc_cache_md.cache_valid == 1) {
        apply (reply_read_hit_after);
    }
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

control ingress {
    process_cache();
    process_value();
    
    apply (ipv4_route);
}

control egress {
    if (nc_hdr.op == NC_READ_REQUEST and nc_cache_md.cache_exist != 1) {
        heavy_hitter();
    }
    apply (ethernet_set_mac);
}
