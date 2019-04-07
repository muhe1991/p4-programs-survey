#define ETHERTYPE_IPV4 0x0800

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

parser start {
    extract(ethernet);
    return select(ethernet.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;
        default : ingress;
    }
}


header ethernet_t ethernet;
header ipv4_t ipv4;

field_list ipv4_checksum_list {
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

field_list_calculation ipv4_checksum {
    input {
        ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field ipv4.hdrChecksum  {
    verify ipv4_checksum;
    update ipv4_checksum;
}

parser parse_ipv4 {
    extract(ipv4);
    return ingress;
}

action _drop() {
    drop();
}

header_type meta_t {
    fields {
        nhop_ipv4 : 32;
    }
}

metadata meta_t meta;

action nat_output(srcAddr, mask1) {
    bit_or(ipv4.srcAddr, ipv4.srcAddr & (~mask1) ,srcAddr & mask1);
}

action nat_input(dstAddr, mask1) {
    bit_or(ipv4.dstAddr, ipv4.dstAddr & (~mask1) ,dstAddr & mask1);
}

table nat {
    reads {
        ipv4.srcAddr : ternary;
        ipv4.dstAddr : ternary;
    }
    actions {
        nat_input;
        nat_output;
    }
}

action set_dmac(dmac, port) {
    modify_field(ethernet.dstAddr, dmac);
    modify_field(standard_metadata.egress_spec, port);
}

table forward {
    reads {
        ipv4.dstAddr : exact;
    }
    actions {
        set_dmac;
        _drop;
    }
}
action set_smac(smac) {
    modify_field(ethernet.srcAddr, smac);
}
table send_frame {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        set_smac;
        _drop;
    }
    size: 256;
}

control ingress {
    if (valid(ipv4)) {
        apply(nat) {
            hit {
                apply(forward);
                apply(send_frame);
            }
        }
        
    }
}