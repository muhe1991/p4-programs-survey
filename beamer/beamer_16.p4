#include <core.p4>
#include <v1model.p4>

struct hash_metadata_t {
    bit<32> mplb_hash;
    bit<32> mplb_hash_modulo;
    bit<8>  recirculate_flag;
}

struct routing_metadata_t {
    bit<32> nhop_ipv4;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header mplb_t {
    bit<8>  tip;
    bit<8>  lengt;
    bit<8>  pointer;
    bit<32> clientip;
    bit<32> virtualip;
    bit<8>  blank;
}

header mplb_ipopt_t {
    bit<1>  copied;
    bit<2>  class;
    bit<5>  number;
    bit<8>  len;
    bit<16> padding;
    bit<32> pdip;
    bit<32> ts;
    bit<32> gen;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> sequence;
    bit<32> ack;
    bit<4>  len;
    bit<6>  reserved;
    bit<6>  flags;
    bit<16> window;
    bit<16> check;
    bit<16> urgent;
}

struct metadata {
    @name(".hash_metadata") 
    hash_metadata_t    hash_metadata;
    @name(".routing_metadata") 
    routing_metadata_t routing_metadata;
}

struct headers {
    @name(".ethernet") 
    ethernet_t   ethernet;
    @name(".inner_ipv4") 
    ipv4_t       inner_ipv4;
    @name(".ipv4") 
    ipv4_t       ipv4;
    @name(".mplb") 
    mplb_t       mplb;
    @name(".mplb_ipopt") 
    mplb_ipopt_t mplb_ipopt;
    @name(".tcp") 
    tcp_t        tcp;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".parse_ethernet") state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name(".parse_inner_ip") state parse_inner_ip {
        packet.extract(hdr.inner_ipv4);
        transition parse_tcp;
    }
    @name(".parse_ipv4") state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            8w4: parse_mplb_ipopt;
            default: parse_tcp;
        }
    }
    @name(".parse_mplb") state parse_mplb {
        packet.extract(hdr.mplb);
        transition parse_tcp;
    }
    @name(".parse_mplb_ipopt") state parse_mplb_ipopt {
        packet.extract(hdr.mplb_ipopt);
        transition parse_inner_ip;
    }
    @name(".parse_tcp") state parse_tcp {
        packet.extract(hdr.tcp);
        transition accept;
    }
    @name(".start") state start {
        transition parse_ethernet;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".rewrite_mac") action rewrite_mac(bit<48> smac) {
        hdr.ethernet.srcAddr = smac;
    }
    @name("._drop") action _drop() {
        mark_to_drop();
    }
    @name(".send_frame") table send_frame {
        actions = {
            rewrite_mac;
            _drop;
        }
        key = {
            standard_metadata.egress_port: exact;
        }
        size = 256;
    }
    apply {
        send_frame.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".set_dmac") action set_dmac(bit<48> dmac) {
        hdr.ethernet.dstAddr = dmac;
    }
    @name("._drop") action _drop() {
        mark_to_drop();
    }
    @name(".set_gen") action set_gen(bit<32> gen) {
        hdr.mplb_ipopt.gen = gen;
    }
    @name(".set_nhop") action set_nhop(bit<32> nhop_ipv4, bit<9> port) {
        meta.routing_metadata.nhop_ipv4 = nhop_ipv4;
        standard_metadata.egress_port = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl + 8w255;
    }
    @name(".calc_modulo") action calc_modulo() {
        meta.hash_metadata.mplb_hash_modulo = meta.hash_metadata.mplb_hash_modulo & ~32w10 | meta.hash_metadata.mplb_hash & 32w10;
    }
    @name(".set_dst") action set_dst(bit<32> dst, bit<32> pdip, bit<32> ts) {
        hdr.mplb_ipopt.setValid();
        hdr.inner_ipv4.setValid();
        hdr.inner_ipv4.version = hdr.ipv4.version;
        hdr.inner_ipv4.protocol = hdr.ipv4.protocol;
        hdr.inner_ipv4.ihl = hdr.ipv4.ihl;
        hdr.inner_ipv4.diffserv = hdr.ipv4.diffserv;
        hdr.inner_ipv4.totalLen = hdr.ipv4.totalLen;
        hdr.inner_ipv4.identification = hdr.ipv4.identification;
        hdr.inner_ipv4.flags = hdr.ipv4.flags;
        hdr.inner_ipv4.fragOffset = hdr.ipv4.fragOffset;
        hdr.inner_ipv4.ttl = hdr.ipv4.ttl;
        hdr.inner_ipv4.protocol = hdr.ipv4.protocol;
        hdr.inner_ipv4.srcAddr = hdr.ipv4.srcAddr;
        hdr.inner_ipv4.dstAddr = hdr.ipv4.dstAddr;
        hdr.mplb_ipopt.class = 2w3;
        hdr.mplb_ipopt.number = 5w1;
        hdr.mplb_ipopt.ts = ts;
        hdr.mplb_ipopt.pdip = pdip;
        hdr.mplb_ipopt.len = 8w16;
        hdr.ipv4.ihl = 4w8;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w36;
        hdr.ipv4.protocol = 8w4;
        hdr.ipv4.srcAddr = hdr.ipv4.dstAddr;
        hdr.ipv4.dstAddr = dst;
    }
    @name(".set_dst_mplb_port") action set_dst_mplb_port(bit<32> dst) {
        hdr.inner_ipv4.setValid();
        hdr.inner_ipv4.protocol = hdr.ipv4.protocol;
        hdr.inner_ipv4.ihl = hdr.ipv4.ihl;
        hdr.inner_ipv4.diffserv = hdr.ipv4.diffserv;
        hdr.inner_ipv4.totalLen = hdr.ipv4.totalLen;
        hdr.inner_ipv4.identification = hdr.ipv4.identification;
        hdr.inner_ipv4.flags = hdr.ipv4.flags;
        hdr.inner_ipv4.fragOffset = hdr.ipv4.fragOffset;
        hdr.inner_ipv4.ttl = hdr.ipv4.ttl;
        hdr.inner_ipv4.version = hdr.ipv4.version;
        hdr.inner_ipv4.srcAddr = hdr.ipv4.srcAddr;
        hdr.inner_ipv4.dstAddr = hdr.ipv4.dstAddr;
        hdr.ipv4.ihl = 4w5;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w20;
        hdr.ipv4.protocol = 8w4;
        hdr.ipv4.srcAddr = hdr.ipv4.dstAddr;
        hdr.ipv4.dstAddr = dst;
    }
    @name("._recirculate") action _recirculate() {
        standard_metadata.egress_port = standard_metadata.ingress_port;
        recirculate({ standard_metadata, meta.hash_metadata });
    }
    @name(".forward") table forward {
        actions = {
            set_dmac;
            _drop;
        }
        key = {
            meta.routing_metadata.nhop_ipv4: exact;
        }
        size = 512;
    }
    @name(".gen") table gen {
        actions = {
            set_gen;
        }
        key = {
            standard_metadata.egress_port: exact;
        }
        size = 2;
    }
    @name(".ipv4_lpm") table ipv4_lpm {
        actions = {
            set_nhop;
            _drop;
        }
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        size = 1024;
    }
    @name(".modulo") table modulo {
        actions = {
            calc_modulo;
        }
        key = {
            meta.hash_metadata.mplb_hash: exact;
        }
        size = 10;
    }
    @name(".mplb") table mplb_0 {
        actions = {
            set_dst;
            _drop;
        }
        key = {
            meta.hash_metadata.mplb_hash_modulo: exact;
        }
        size = 1024;
    }
    @name(".mplb_port") table mplb_port {
        actions = {
            set_dst_mplb_port;
            _drop;
        }
        key = {
            hdr.tcp.dstPort: exact;
        }
        size = 65536;
    }
    @name(".recirc") table recirc {
        actions = {
            _recirculate;
        }
        key = {
            hdr.ipv4.srcAddr: exact;
        }
        size = 2;
    }
    apply {
        if (standard_metadata.instance_type == 32w0) {
            recirc.apply();
        }
        else {
            if (hdr.ipv4.isValid() && hdr.ipv4.ttl > 8w0) {
                if (hdr.tcp.dstPort < 16w1024) {
                    modulo.apply();
                    gen.apply();
                    mplb_0.apply();
                }
                else {
                    mplb_port.apply();
                }
                ipv4_lpm.apply();
                forward.apply();
            }
        }
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.mplb_ipopt);
        packet.emit(hdr.inner_ipv4);
        packet.emit(hdr.tcp);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
        update_checksum(true, { hdr.ipv4.srcAddr, hdr.tcp.srcPort }, meta.hash_metadata.mplb_hash, HashAlgorithm.crc32);
        update_checksum(hdr.ipv4.isValid(), { hdr.inner_ipv4.version, hdr.inner_ipv4.ihl, hdr.inner_ipv4.diffserv, hdr.inner_ipv4.totalLen, hdr.inner_ipv4.identification, hdr.inner_ipv4.flags, hdr.inner_ipv4.fragOffset, hdr.inner_ipv4.ttl, hdr.inner_ipv4.protocol, hdr.inner_ipv4.srcAddr, hdr.inner_ipv4.dstAddr }, hdr.inner_ipv4.hdrChecksum, HashAlgorithm.csum16);
        update_checksum(true, { hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv, hdr.ipv4.totalLen, hdr.ipv4.identification, hdr.ipv4.flags, hdr.ipv4.fragOffset, hdr.ipv4.ttl, hdr.ipv4.protocol, hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.mplb_ipopt.copied, hdr.mplb_ipopt.class, hdr.mplb_ipopt.number, hdr.mplb_ipopt.len, hdr.mplb_ipopt.ts, hdr.mplb_ipopt.pdip }, hdr.ipv4.hdrChecksum, HashAlgorithm.csum16);
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

