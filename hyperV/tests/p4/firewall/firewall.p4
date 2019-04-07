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

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        len     : 16;
        checksum: 16;
    }
}

header ethernet_t ethernet;
header ipv4_t ipv4;
header tcp_t  tcp;
header udp_t  udp;

#define ETHERTYPE_IPv4 0x0806
#define IPPROTCOL_UDP 17
#define IPPROTCOL_TCP 6
parser start {
    extract(ethernet);
    return select(ethernet.etherType) {
        ETHERTYPE_IPv4 : ipv4_parser;
        default : ingress;
    }
}

parser ipv4_parser {
    extract(ipv4);
    return select(ipv4.protocol) {
        IPPROTCOL_TCP : tcp_parser;
        IPPROTCOL_UDP : udp_parser;
        default : ingress;
    }
}

parser tcp_parser {
    extract(tcp);
    return ingress;
}

parser udp_parser {
    extract(udp);
    return ingress;
}

action block() {
    drop();
}

action noop() {
    no_op();
}
action forward(port) {
    modify_field(standard_metadata.egress_spec, port);
}

table firewall_with_tcp {
    reads {
        ipv4.srcAddr : ternary;
        ipv4.dstAddr : ternary;
        tcp.srcPort  : ternary;
        tcp.dstPort  : ternary;
    }
    actions {
        block;
        noop;
    }
}

table firewall_with_udp {
    reads {
        ipv4.srcAddr : ternary;
        ipv4.dstAddr : ternary;
        udp.srcPort  : ternary;
        udp.dstPort  : ternary;
    }
    actions {
        block;
        noop;
    }
}

table forward_table {
    reads {
        standard_metadata.ingress_port : exact;
    }
    actions {
        forward;
    }
}
control ingress {
    apply(forward_table);
    if (valid(ipv4)) {
        if(valid(udp)) {
            apply(firewall_with_udp);
        }
        else if(valid(tcp)) {
            apply(firewall_with_tcp);
        }
    }
}
