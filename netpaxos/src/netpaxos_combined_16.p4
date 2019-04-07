#include <core.p4>
#include <v1model.p4>

struct local_metadata_t {
    bit<32> inst;
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
    bit<32> src;
    bit<32> dst;
}

header paxos_t {
    bit<32> inst;
    bit<16> proposal;
    bit<16> vproposal;
    bit<16> acpt;
    bit<16> msgtype;
    bit<32> val;
    bit<32> fsh;
    bit<32> fsl;
    bit<32> feh;
    bit<32> fel;
    bit<32> csh;
    bit<32> csl;
    bit<32> ceh;
    bit<32> cel;
    bit<32> ash;
    bit<32> asl;
    bit<32> aeh;
    bit<32> ael;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> length_;
    bit<16> checksum;
}

struct metadata {
    local_metadata_t local_metadata;
}

struct headers {
    ethernet_t ethernet;
    ipv4_t     ipv4;
    paxos_t    paxos;
    udp_t      udp;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    state start {
        transition parse_ethernet;
    }
    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            default: accept;
        }
    }
    state parse_udp {
        packet.extract(hdr.udp);
        transition select(hdr.udp.dstPort) {
            16w0x8888: parse_paxos;
            default: accept;
        }
    }
    state parse_paxos {
        packet.extract(hdr.paxos);
        transition accept;
    }   
}


control ingressinout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    /* Device-related register */
    register<bit<1>>(32w1) is_coordinator;
    /* Register in coordinator */
    register<bit<32>>(32w64000) inst_register;
    /* Register in acceptor */
    register<bit<16>>(32w1) acceptor_id;
    register<bit<16>>(32w64000) proposal_register;
    register<bit<32>>(32w64000) val_register;
    register<bit<16>>(32w64000) vproposal_register;

    action _no_op() {
    }
    action forward(bit<9> port) {
        _no_op();
        standard_metadata.egress_spec = port;
        _no_op();
    }
    action _drop() {
        mark_to_drop();
    }
    action increase_sequence() {
        _no_op();
        inst_register.read(meta.local_metadata.inst, (bit<32>)0);
        hdr.paxos.inst = meta.local_metadata.inst;
        meta.local_metadata.inst = meta.local_metadata.inst + 32w1;
        inst_register.write((bit<32>)0, (bit<32>)meta.local_metadata.inst);
        hdr.paxos.msgtype = 16w3;
        hdr.udp.checksum = 16w0;
        _no_op();
    }
    action reset_paxos() {
        meta.local_metadata.inst = 32w0;
        inst_register.write((bit<32>)0, (bit<32>)meta.local_metadata.inst);
    }
    action handle_phase1a() {
        _no_op();
        proposal_register.write((bit<32>)hdr.paxos.inst, (bit<16>)hdr.paxos.proposal);
        vproposal_register.read(hdr.paxos.vproposal, (bit<32>)hdr.paxos.inst);
        val_register.read(hdr.paxos.val, (bit<32>)hdr.paxos.inst);
        hdr.paxos.msgtype = 16w2;
        acceptor_id.read(hdr.paxos.acpt, (bit<32>)0);
        hdr.udp.checksum = 16w0;
        _no_op();
    }
    action handle_phase2a() {
        _no_op();
        proposal_register.write((bit<32>)hdr.paxos.inst, (bit<16>)hdr.paxos.proposal);
        vproposal_register.write((bit<32>)hdr.paxos.inst, (bit<16>)hdr.paxos.proposal);
        val_register.write((bit<32>)hdr.paxos.inst, (bit<32>)hdr.paxos.val);
        hdr.paxos.msgtype = 16w4;
        hdr.paxos.vproposal = hdr.paxos.proposal;
        acceptor_id.read(hdr.paxos.acpt, (bit<32>)0);
        hdr.udp.checksum = 16w0;
        _no_op();
    }
    action read_round() {
        proposal_register.read(meta.local_metadata.proposal, (bit<32>)hdr.paxos.inst);
    }
    table fwd_tbl {
        actions = {
            forward;
            _drop;
        }
        key = {
            standard_metadata.ingress_port: exact;
        }
        size = 8;
    }
    table paxos_tbl_coordinator {
        actions = {
            increase_sequence;
            reset_paxos;
            _no_op;
        }
        key = {
            hdr.paxos.msgtype: exact;
        }
        size = 8;
    }
    table paxos_tbl_acceptor {
        actions = {
            handle_phase1a;
            handle_phase2a;
            _no_op;
        }
        key = {
            hdr.paxos.msgtype: exact;
        }
        size = 8;
    }
    table round_tbl {
        actions = {
            read_round;
        }
        size = 1;
    }
    table drop_tbl {
        actions = {
            _drop;
        }
        size = 1;
    }
    apply {
        if (hdr.ipv4.isValid()) {
            fwd_tbl.apply();
        }
        if (hdr.paxos.isValid()) {
            bit<1> is_coordinator_flag;
            is_coordinator.read(is_coordinator_flag, (bit<32>)0);
            if (is_coordinator_flag == 1)
            {
                paxos_tbl_coordinator.apply();
            } else {
                round_tbl.apply();
                if (meta.local_metadata.proposal <= hdr.paxos.proposal) {
                    paxos_tbl_acceptor.apply();
                }
                else {
                    drop_tbl.apply();
                }
            }
        }
    }
}
