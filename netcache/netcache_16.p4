#include <core.p4>
#include <v1model.p4>

struct hh_bf_md_t {
    bit<16> index_1;
    bit<16> index_2;
    bit<16> index_3;
    bit<1>  bf_1;
    bit<1>  bf_2;
    bit<1>  bf_3;
}

struct nc_cache_md_t {
    bit<1>  cache_exist;
    bit<14> cache_index;
    bit<1>  cache_valid;
}

struct nc_load_md_t {
    bit<16> index_1;
    bit<16> index_2;
    bit<16> index_3;
    bit<16> index_4;
    bit<32> load_1;
    bit<32> load_2;
    bit<32> load_3;
    bit<32> load_4;
}

struct reply_read_hit_info_md_t {
    bit<32> ipv4_srcAddr;
    bit<32> ipv4_dstAddr;
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

header nc_hdr_t {
    bit<8>   op;
    bit<128> key;
}

header nc_load_t {
    bit<32> load_1;
    bit<32> load_2;
    bit<32> load_3;
    bit<32> load_4;
}

header nc_value_1_t {
    bit<32> value_1_1;
    bit<32> value_1_2;
    bit<32> value_1_3;
    bit<32> value_1_4;
}

header nc_value_2_t {
    bit<32> value_2_1;
    bit<32> value_2_2;
    bit<32> value_2_3;
    bit<32> value_2_4;
}

header nc_value_3_t {
    bit<32> value_3_1;
    bit<32> value_3_2;
    bit<32> value_3_3;
    bit<32> value_3_4;
}

header nc_value_4_t {
    bit<32> value_4_1;
    bit<32> value_4_2;
    bit<32> value_4_3;
    bit<32> value_4_4;
}

header nc_value_5_t {
    bit<32> value_5_1;
    bit<32> value_5_2;
    bit<32> value_5_3;
    bit<32> value_5_4;
}

header nc_value_6_t {
    bit<32> value_6_1;
    bit<32> value_6_2;
    bit<32> value_6_3;
    bit<32> value_6_4;
}

header nc_value_7_t {
    bit<32> value_7_1;
    bit<32> value_7_2;
    bit<32> value_7_3;
    bit<32> value_7_4;
}

header nc_value_8_t {
    bit<32> value_8_1;
    bit<32> value_8_2;
    bit<32> value_8_3;
    bit<32> value_8_4;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> len;
    bit<16> checksum;
}

struct metadata {
    @name(".hh_bf_md") 
    hh_bf_md_t               hh_bf_md;
    @name(".nc_cache_md") 
    nc_cache_md_t            nc_cache_md;
    @name(".nc_load_md") 
    nc_load_md_t             nc_load_md;
    @name(".reply_read_hit_info_md") 
    reply_read_hit_info_md_t reply_read_hit_info_md;
}

struct headers {
    @name(".ethernet") 
    ethernet_t   ethernet;
    @name(".ipv4") 
    ipv4_t       ipv4;
    @name(".nc_hdr") 
    nc_hdr_t     nc_hdr;
    @name(".nc_load") 
    nc_load_t    nc_load;
    @name(".nc_value_1") 
    nc_value_1_t nc_value_1;
    @name(".nc_value_2") 
    nc_value_2_t nc_value_2;
    @name(".nc_value_3") 
    nc_value_3_t nc_value_3;
    @name(".nc_value_4") 
    nc_value_4_t nc_value_4;
    @name(".nc_value_5") 
    nc_value_5_t nc_value_5;
    @name(".nc_value_6") 
    nc_value_6_t nc_value_6;
    @name(".nc_value_7") 
    nc_value_7_t nc_value_7;
    @name(".nc_value_8") 
    nc_value_8_t nc_value_8;
    @name(".tcp") 
    tcp_t        tcp;
    @name(".udp") 
    udp_t        udp;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".parse_ethernet") state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name(".parse_ipv4") state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            8w6: parse_tcp;
            8w17: parse_udp;
            default: accept;
        }
    }
    @name(".parse_nc_hdr") state parse_nc_hdr {
        packet.extract(hdr.nc_hdr);
        transition select(hdr.nc_hdr.op) {
            8w0: accept;
            8w1: parse_value;
            8w2: parse_nc_load;
            8w8: accept;
            8w9: parse_value;
            default: accept;
        }
    }
    @name(".parse_nc_load") state parse_nc_load {
        packet.extract(hdr.nc_load);
        transition accept;
    }
    @name(".parse_nc_value_1") state parse_nc_value_1 {
        packet.extract(hdr.nc_value_1);
        transition parse_nc_value_2;
    }
    @name(".parse_nc_value_2") state parse_nc_value_2 {
        packet.extract(hdr.nc_value_2);
        transition parse_nc_value_3;
    }
    @name(".parse_nc_value_3") state parse_nc_value_3 {
        packet.extract(hdr.nc_value_3);
        transition parse_nc_value_4;
    }
    @name(".parse_nc_value_4") state parse_nc_value_4 {
        packet.extract(hdr.nc_value_4);
        transition parse_nc_value_5;
    }
    @name(".parse_nc_value_5") state parse_nc_value_5 {
        packet.extract(hdr.nc_value_5);
        transition parse_nc_value_6;
    }
    @name(".parse_nc_value_6") state parse_nc_value_6 {
        packet.extract(hdr.nc_value_6);
        transition parse_nc_value_7;
    }
    @name(".parse_nc_value_7") state parse_nc_value_7 {
        packet.extract(hdr.nc_value_7);
        transition parse_nc_value_8;
    }
    @name(".parse_nc_value_8") state parse_nc_value_8 {
        packet.extract(hdr.nc_value_8);
        transition parse_nc_value_9;
    }
    @name(".parse_nc_value_9") state parse_nc_value_9 {
        transition accept;
    }
    @name(".parse_tcp") state parse_tcp {
        packet.extract(hdr.tcp);
        transition accept;
    }
    @name(".parse_udp") state parse_udp {
        packet.extract(hdr.udp);
        transition select(hdr.udp.dstPort) {
            16w8888: parse_nc_hdr;
            default: accept;
        }
    }
    @name(".parse_value") state parse_value {
        transition parse_nc_value_1;
    }
    @name(".start") state start {
        transition parse_ethernet;
    }
}

control bloom_filter(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".hh_bf_1_reg") register<bit<1>>(32w512) hh_bf_1_reg;
    @name(".hh_bf_2_reg") register<bit<1>>(32w512) hh_bf_2_reg;
    @name(".hh_bf_3_reg") register<bit<1>>(32w512) hh_bf_3_reg;
    @name(".hh_bf_1_act") action hh_bf_1_act() {
        hash(meta.hh_bf_md.index_1, HashAlgorithm.crc32, (bit<9>)0, { hdr.nc_hdr.key }, (bit<18>)512);
        hh_bf_1_reg.read(meta.hh_bf_md.bf_1, (bit<32>)meta.hh_bf_md.index_1);
        hh_bf_1_reg.write((bit<32>)meta.hh_bf_md.index_1, (bit<1>)1);
    }
    @name(".hh_bf_2_act") action hh_bf_2_act() {
        hash(meta.hh_bf_md.index_2, HashAlgorithm.csum16, (bit<9>)0, { hdr.nc_hdr.key }, (bit<18>)512);
        hh_bf_2_reg.read(meta.hh_bf_md.bf_2, (bit<32>)meta.hh_bf_md.index_2);
        hh_bf_2_reg.write((bit<32>)meta.hh_bf_md.index_2, (bit<1>)1);
    }
    @name(".hh_bf_3_act") action hh_bf_3_act() {
        hash(meta.hh_bf_md.index_3, HashAlgorithm.crc16, (bit<9>)0, { hdr.nc_hdr.key }, (bit<18>)512);
        hh_bf_3_reg.read(meta.hh_bf_md.bf_3, (bit<32>)meta.hh_bf_md.index_3);
        hh_bf_3_reg.write((bit<32>)meta.hh_bf_md.index_3, (bit<1>)1);
    }
    @name(".hh_bf_1") table hh_bf_1 {
        actions = {
            hh_bf_1_act;
        }
    }
    @name(".hh_bf_2") table hh_bf_2 {
        actions = {
            hh_bf_2_act;
        }
    }
    @name(".hh_bf_3") table hh_bf_3 {
        actions = {
            hh_bf_3_act;
        }
    }
    apply {
        hh_bf_1.apply();
        hh_bf_2.apply();
        hh_bf_3.apply();
    }
}

control count_min(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".hh_load_1_reg") register<bit<32>>(32w256) hh_load_1_reg;
    @name(".hh_load_2_reg") register<bit<32>>(32w256) hh_load_2_reg;
    @name(".hh_load_3_reg") register<bit<32>>(32w256) hh_load_3_reg;
    @name(".hh_load_4_reg") register<bit<32>>(32w256) hh_load_4_reg;
    @name(".hh_load_1_count_act") action hh_load_1_count_act() {
        hash(meta.nc_load_md.index_1, HashAlgorithm.crc32, (bit<8>)0, { hdr.nc_hdr.key }, (bit<16>)256);
        hh_load_1_reg.read(meta.nc_load_md.load_1, (bit<32>)meta.nc_load_md.index_1);
        hh_load_1_reg.write((bit<32>)meta.nc_load_md.index_1, (bit<32>)(meta.nc_load_md.load_1 + 32w1));
    }
    @name(".hh_load_2_count_act") action hh_load_2_count_act() {
        hash(meta.nc_load_md.index_2, HashAlgorithm.csum16, (bit<8>)0, { hdr.nc_hdr.key }, (bit<16>)256);
        hh_load_2_reg.read(meta.nc_load_md.load_2, (bit<32>)meta.nc_load_md.index_2);
        hh_load_2_reg.write((bit<32>)meta.nc_load_md.index_2, (bit<32>)(meta.nc_load_md.load_2 + 32w1));
    }
    @name(".hh_load_3_count_act") action hh_load_3_count_act() {
        hash(meta.nc_load_md.index_3, HashAlgorithm.crc16, (bit<8>)0, { hdr.nc_hdr.key }, (bit<16>)256);
        hh_load_3_reg.read(meta.nc_load_md.load_3, (bit<32>)meta.nc_load_md.index_3);
        hh_load_3_reg.write((bit<32>)meta.nc_load_md.index_3, (bit<32>)(meta.nc_load_md.load_3 + 32w1));
    }
    @name(".hh_load_4_count_act") action hh_load_4_count_act() {
        hash(meta.nc_load_md.index_4, HashAlgorithm.crc32, (bit<8>)0, { hdr.nc_hdr.key }, (bit<16>)256);
        hh_load_4_reg.read(meta.nc_load_md.load_4, (bit<32>)meta.nc_load_md.index_4);
        hh_load_4_reg.write((bit<32>)meta.nc_load_md.index_4, (bit<32>)(meta.nc_load_md.load_4 + 32w1));
    }
    @name(".hh_load_1_count") table hh_load_1_count {
        actions = {
            hh_load_1_count_act;
        }
    }
    @name(".hh_load_2_count") table hh_load_2_count {
        actions = {
            hh_load_2_count_act;
        }
    }
    @name(".hh_load_3_count") table hh_load_3_count {
        actions = {
            hh_load_3_count_act;
        }
    }
    @name(".hh_load_4_count") table hh_load_4_count {
        actions = {
            hh_load_4_count_act;
        }
    }
    apply {
        hh_load_1_count.apply();
        hh_load_2_count.apply();
        hh_load_3_count.apply();
        hh_load_4_count.apply();
    }
}

control report_hot_step_1(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".clone_to_controller_act") action clone_to_controller_act() {
        clone3(CloneType.E2E, (bit<32>)32w3, { meta.nc_load_md.load_1, meta.nc_load_md.load_2, meta.nc_load_md.load_3, meta.nc_load_md.load_4 });
    }
    @name(".clone_to_controller") table clone_to_controller {
        actions = {
            clone_to_controller_act;
        }
    }
    apply {
        clone_to_controller.apply();
    }
}

control report_hot_step_2(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".report_hot_act") action report_hot_act() {
        hdr.nc_hdr.op = 8w2;
        hdr.nc_load.setValid();
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_load.load_1 = meta.nc_load_md.load_1;
        hdr.nc_load.load_2 = meta.nc_load_md.load_2;
        hdr.nc_load.load_3 = meta.nc_load_md.load_3;
        hdr.nc_load.load_4 = meta.nc_load_md.load_4;
        hdr.ipv4.dstAddr = 32w0xa000003;
    }
    @name(".report_hot") table report_hot {
        actions = {
            report_hot_act;
        }
    }
    apply {
        report_hot.apply();
    }
}

control heavy_hitter(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".count_min") count_min() count_min_0;
    @name(".bloom_filter") bloom_filter() bloom_filter_0;
    @name(".report_hot_step_1") report_hot_step_1() report_hot_step_1_0;
    @name(".report_hot_step_2") report_hot_step_2() report_hot_step_2_0;
    apply {
        if (standard_metadata.instance_type == 32w0) {
            count_min_0.apply(hdr, meta, standard_metadata);
            if (meta.nc_load_md.load_1 > 32w128) {
                if (meta.nc_load_md.load_2 > 32w128) {
                    if (meta.nc_load_md.load_3 > 32w128) {
                        if (meta.nc_load_md.load_4 > 32w128) {
                            bloom_filter_0.apply(hdr, meta, standard_metadata);
                            if (meta.hh_bf_md.bf_1 == 1w0 || meta.hh_bf_md.bf_2 == 1w0 || meta.hh_bf_md.bf_3 == 1w0) {
                                report_hot_step_1_0.apply(hdr, meta, standard_metadata);
                            }
                        }
                    }
                }
            }
        }
        else {
            report_hot_step_2_0.apply(hdr, meta, standard_metadata);
        }
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".ethernet_set_mac_act") action ethernet_set_mac_act(bit<48> smac, bit<48> dmac) {
        hdr.ethernet.srcAddr = smac;
        hdr.ethernet.dstAddr = dmac;
    }
    @name(".ethernet_set_mac") table ethernet_set_mac {
        actions = {
            ethernet_set_mac_act;
        }
        key = {
            standard_metadata.egress_port: exact;
        }
    }
    @name(".heavy_hitter") heavy_hitter() heavy_hitter_0;
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_exist != 1w1) {
            heavy_hitter_0.apply(hdr, meta, standard_metadata);
        }
        ethernet_set_mac.apply();
    }
}

control process_cache(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".cache_valid_reg") register<bit<1>>(32w128) cache_valid_reg;
    @name(".check_cache_exist_act") action check_cache_exist_act(bit<14> index) {
        meta.nc_cache_md.cache_exist = 1w1;
        meta.nc_cache_md.cache_index = index;
    }
    @name(".check_cache_valid_act") action check_cache_valid_act() {
        cache_valid_reg.read(meta.nc_cache_md.cache_valid, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".set_cache_valid_act") action set_cache_valid_act() {
        cache_valid_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<1>)1);
    }
    @name(".check_cache_exist") table check_cache_exist {
        actions = {
            check_cache_exist_act;
        }
        key = {
            hdr.nc_hdr.key: exact;
        }
        size = 128;
    }
    @name(".check_cache_valid") table check_cache_valid {
        actions = {
            check_cache_valid_act;
        }
    }
    @name(".set_cache_valid") table set_cache_valid {
        actions = {
            set_cache_valid_act;
        }
    }
    apply {
        check_cache_exist.apply();
        if (meta.nc_cache_md.cache_exist == 1w1) {
            if (hdr.nc_hdr.op == 8w0) {
                check_cache_valid.apply();
            }
            else {
                if (hdr.nc_hdr.op == 8w9) {
                    set_cache_valid.apply();
                }
            }
        }
    }
}

control process_value_1(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_1_1_reg") register<bit<32>>(32w128) value_1_1_reg;
    @name(".value_1_2_reg") register<bit<32>>(32w128) value_1_2_reg;
    @name(".value_1_3_reg") register<bit<32>>(32w128) value_1_3_reg;
    @name(".value_1_4_reg") register<bit<32>>(32w128) value_1_4_reg;
    @name(".add_value_header_1_act") action add_value_header_1_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_1.setValid();
    }
    @name(".read_value_1_1_act") action read_value_1_1_act() {
        value_1_1_reg.read(hdr.nc_value_1.value_1_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_1_2_act") action read_value_1_2_act() {
        value_1_2_reg.read(hdr.nc_value_1.value_1_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_1_3_act") action read_value_1_3_act() {
        value_1_3_reg.read(hdr.nc_value_1.value_1_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_1_4_act") action read_value_1_4_act() {
        value_1_4_reg.read(hdr.nc_value_1.value_1_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_1_act") action remove_value_header_1_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_1.setInvalid();
    }
    @name(".write_value_1_1_act") action write_value_1_1_act() {
        value_1_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_1.value_1_1);
    }
    @name(".write_value_1_2_act") action write_value_1_2_act() {
        value_1_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_1.value_1_2);
    }
    @name(".write_value_1_3_act") action write_value_1_3_act() {
        value_1_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_1.value_1_3);
    }
    @name(".write_value_1_4_act") action write_value_1_4_act() {
        value_1_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_1.value_1_4);
    }
    @name(".add_value_header_1") table add_value_header_1 {
        actions = {
            add_value_header_1_act;
        }
    }
    @name(".read_value_1_1") table read_value_1_1 {
        actions = {
            read_value_1_1_act;
        }
    }
    @name(".read_value_1_2") table read_value_1_2 {
        actions = {
            read_value_1_2_act;
        }
    }
    @name(".read_value_1_3") table read_value_1_3 {
        actions = {
            read_value_1_3_act;
        }
    }
    @name(".read_value_1_4") table read_value_1_4 {
        actions = {
            read_value_1_4_act;
        }
    }
    @name(".remove_value_header_1") table remove_value_header_1 {
        actions = {
            remove_value_header_1_act;
        }
    }
    @name(".write_value_1_1") table write_value_1_1 {
        actions = {
            write_value_1_1_act;
        }
    }
    @name(".write_value_1_2") table write_value_1_2 {
        actions = {
            write_value_1_2_act;
        }
    }
    @name(".write_value_1_3") table write_value_1_3 {
        actions = {
            write_value_1_3_act;
        }
    }
    @name(".write_value_1_4") table write_value_1_4 {
        actions = {
            write_value_1_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_1.apply();
            read_value_1_1.apply();
            read_value_1_2.apply();
            read_value_1_3.apply();
            read_value_1_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_1_1.apply();
                write_value_1_2.apply();
                write_value_1_3.apply();
                write_value_1_4.apply();
                remove_value_header_1.apply();
            }
        }
    }
}

control process_value_2(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_2_1_reg") register<bit<32>>(32w128) value_2_1_reg;
    @name(".value_2_2_reg") register<bit<32>>(32w128) value_2_2_reg;
    @name(".value_2_3_reg") register<bit<32>>(32w128) value_2_3_reg;
    @name(".value_2_4_reg") register<bit<32>>(32w128) value_2_4_reg;
    @name(".add_value_header_2_act") action add_value_header_2_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_2.setValid();
    }
    @name(".read_value_2_1_act") action read_value_2_1_act() {
        value_2_1_reg.read(hdr.nc_value_2.value_2_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_2_2_act") action read_value_2_2_act() {
        value_2_2_reg.read(hdr.nc_value_2.value_2_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_2_3_act") action read_value_2_3_act() {
        value_2_3_reg.read(hdr.nc_value_2.value_2_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_2_4_act") action read_value_2_4_act() {
        value_2_4_reg.read(hdr.nc_value_2.value_2_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_2_act") action remove_value_header_2_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_2.setInvalid();
    }
    @name(".write_value_2_1_act") action write_value_2_1_act() {
        value_2_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_2.value_2_1);
    }
    @name(".write_value_2_2_act") action write_value_2_2_act() {
        value_2_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_2.value_2_2);
    }
    @name(".write_value_2_3_act") action write_value_2_3_act() {
        value_2_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_2.value_2_3);
    }
    @name(".write_value_2_4_act") action write_value_2_4_act() {
        value_2_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_2.value_2_4);
    }
    @name(".add_value_header_2") table add_value_header_2 {
        actions = {
            add_value_header_2_act;
        }
    }
    @name(".read_value_2_1") table read_value_2_1 {
        actions = {
            read_value_2_1_act;
        }
    }
    @name(".read_value_2_2") table read_value_2_2 {
        actions = {
            read_value_2_2_act;
        }
    }
    @name(".read_value_2_3") table read_value_2_3 {
        actions = {
            read_value_2_3_act;
        }
    }
    @name(".read_value_2_4") table read_value_2_4 {
        actions = {
            read_value_2_4_act;
        }
    }
    @name(".remove_value_header_2") table remove_value_header_2 {
        actions = {
            remove_value_header_2_act;
        }
    }
    @name(".write_value_2_1") table write_value_2_1 {
        actions = {
            write_value_2_1_act;
        }
    }
    @name(".write_value_2_2") table write_value_2_2 {
        actions = {
            write_value_2_2_act;
        }
    }
    @name(".write_value_2_3") table write_value_2_3 {
        actions = {
            write_value_2_3_act;
        }
    }
    @name(".write_value_2_4") table write_value_2_4 {
        actions = {
            write_value_2_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_2.apply();
            read_value_2_1.apply();
            read_value_2_2.apply();
            read_value_2_3.apply();
            read_value_2_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_2_1.apply();
                write_value_2_2.apply();
                write_value_2_3.apply();
                write_value_2_4.apply();
                remove_value_header_2.apply();
            }
        }
    }
}

control process_value_3(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_3_1_reg") register<bit<32>>(32w128) value_3_1_reg;
    @name(".value_3_2_reg") register<bit<32>>(32w128) value_3_2_reg;
    @name(".value_3_3_reg") register<bit<32>>(32w128) value_3_3_reg;
    @name(".value_3_4_reg") register<bit<32>>(32w128) value_3_4_reg;
    @name(".add_value_header_3_act") action add_value_header_3_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_3.setValid();
    }
    @name(".read_value_3_1_act") action read_value_3_1_act() {
        value_3_1_reg.read(hdr.nc_value_3.value_3_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_3_2_act") action read_value_3_2_act() {
        value_3_2_reg.read(hdr.nc_value_3.value_3_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_3_3_act") action read_value_3_3_act() {
        value_3_3_reg.read(hdr.nc_value_3.value_3_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_3_4_act") action read_value_3_4_act() {
        value_3_4_reg.read(hdr.nc_value_3.value_3_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_3_act") action remove_value_header_3_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_3.setInvalid();
    }
    @name(".write_value_3_1_act") action write_value_3_1_act() {
        value_3_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_3.value_3_1);
    }
    @name(".write_value_3_2_act") action write_value_3_2_act() {
        value_3_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_3.value_3_2);
    }
    @name(".write_value_3_3_act") action write_value_3_3_act() {
        value_3_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_3.value_3_3);
    }
    @name(".write_value_3_4_act") action write_value_3_4_act() {
        value_3_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_3.value_3_4);
    }
    @name(".add_value_header_3") table add_value_header_3 {
        actions = {
            add_value_header_3_act;
        }
    }
    @name(".read_value_3_1") table read_value_3_1 {
        actions = {
            read_value_3_1_act;
        }
    }
    @name(".read_value_3_2") table read_value_3_2 {
        actions = {
            read_value_3_2_act;
        }
    }
    @name(".read_value_3_3") table read_value_3_3 {
        actions = {
            read_value_3_3_act;
        }
    }
    @name(".read_value_3_4") table read_value_3_4 {
        actions = {
            read_value_3_4_act;
        }
    }
    @name(".remove_value_header_3") table remove_value_header_3 {
        actions = {
            remove_value_header_3_act;
        }
    }
    @name(".write_value_3_1") table write_value_3_1 {
        actions = {
            write_value_3_1_act;
        }
    }
    @name(".write_value_3_2") table write_value_3_2 {
        actions = {
            write_value_3_2_act;
        }
    }
    @name(".write_value_3_3") table write_value_3_3 {
        actions = {
            write_value_3_3_act;
        }
    }
    @name(".write_value_3_4") table write_value_3_4 {
        actions = {
            write_value_3_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_3.apply();
            read_value_3_1.apply();
            read_value_3_2.apply();
            read_value_3_3.apply();
            read_value_3_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_3_1.apply();
                write_value_3_2.apply();
                write_value_3_3.apply();
                write_value_3_4.apply();
                remove_value_header_3.apply();
            }
        }
    }
}

control process_value_4(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_4_1_reg") register<bit<32>>(32w128) value_4_1_reg;
    @name(".value_4_2_reg") register<bit<32>>(32w128) value_4_2_reg;
    @name(".value_4_3_reg") register<bit<32>>(32w128) value_4_3_reg;
    @name(".value_4_4_reg") register<bit<32>>(32w128) value_4_4_reg;
    @name(".add_value_header_4_act") action add_value_header_4_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_4.setValid();
    }
    @name(".read_value_4_1_act") action read_value_4_1_act() {
        value_4_1_reg.read(hdr.nc_value_4.value_4_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_4_2_act") action read_value_4_2_act() {
        value_4_2_reg.read(hdr.nc_value_4.value_4_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_4_3_act") action read_value_4_3_act() {
        value_4_3_reg.read(hdr.nc_value_4.value_4_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_4_4_act") action read_value_4_4_act() {
        value_4_4_reg.read(hdr.nc_value_4.value_4_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_4_act") action remove_value_header_4_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_4.setInvalid();
    }
    @name(".write_value_4_1_act") action write_value_4_1_act() {
        value_4_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_4.value_4_1);
    }
    @name(".write_value_4_2_act") action write_value_4_2_act() {
        value_4_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_4.value_4_2);
    }
    @name(".write_value_4_3_act") action write_value_4_3_act() {
        value_4_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_4.value_4_3);
    }
    @name(".write_value_4_4_act") action write_value_4_4_act() {
        value_4_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_4.value_4_4);
    }
    @name(".add_value_header_4") table add_value_header_4 {
        actions = {
            add_value_header_4_act;
        }
    }
    @name(".read_value_4_1") table read_value_4_1 {
        actions = {
            read_value_4_1_act;
        }
    }
    @name(".read_value_4_2") table read_value_4_2 {
        actions = {
            read_value_4_2_act;
        }
    }
    @name(".read_value_4_3") table read_value_4_3 {
        actions = {
            read_value_4_3_act;
        }
    }
    @name(".read_value_4_4") table read_value_4_4 {
        actions = {
            read_value_4_4_act;
        }
    }
    @name(".remove_value_header_4") table remove_value_header_4 {
        actions = {
            remove_value_header_4_act;
        }
    }
    @name(".write_value_4_1") table write_value_4_1 {
        actions = {
            write_value_4_1_act;
        }
    }
    @name(".write_value_4_2") table write_value_4_2 {
        actions = {
            write_value_4_2_act;
        }
    }
    @name(".write_value_4_3") table write_value_4_3 {
        actions = {
            write_value_4_3_act;
        }
    }
    @name(".write_value_4_4") table write_value_4_4 {
        actions = {
            write_value_4_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_4.apply();
            read_value_4_1.apply();
            read_value_4_2.apply();
            read_value_4_3.apply();
            read_value_4_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_4_1.apply();
                write_value_4_2.apply();
                write_value_4_3.apply();
                write_value_4_4.apply();
                remove_value_header_4.apply();
            }
        }
    }
}

control process_value_5(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_5_1_reg") register<bit<32>>(32w128) value_5_1_reg;
    @name(".value_5_2_reg") register<bit<32>>(32w128) value_5_2_reg;
    @name(".value_5_3_reg") register<bit<32>>(32w128) value_5_3_reg;
    @name(".value_5_4_reg") register<bit<32>>(32w128) value_5_4_reg;
    @name(".add_value_header_5_act") action add_value_header_5_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_5.setValid();
    }
    @name(".read_value_5_1_act") action read_value_5_1_act() {
        value_5_1_reg.read(hdr.nc_value_5.value_5_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_5_2_act") action read_value_5_2_act() {
        value_5_2_reg.read(hdr.nc_value_5.value_5_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_5_3_act") action read_value_5_3_act() {
        value_5_3_reg.read(hdr.nc_value_5.value_5_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_5_4_act") action read_value_5_4_act() {
        value_5_4_reg.read(hdr.nc_value_5.value_5_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_5_act") action remove_value_header_5_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_5.setInvalid();
    }
    @name(".write_value_5_1_act") action write_value_5_1_act() {
        value_5_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_5.value_5_1);
    }
    @name(".write_value_5_2_act") action write_value_5_2_act() {
        value_5_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_5.value_5_2);
    }
    @name(".write_value_5_3_act") action write_value_5_3_act() {
        value_5_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_5.value_5_3);
    }
    @name(".write_value_5_4_act") action write_value_5_4_act() {
        value_5_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_5.value_5_4);
    }
    @name(".add_value_header_5") table add_value_header_5 {
        actions = {
            add_value_header_5_act;
        }
    }
    @name(".read_value_5_1") table read_value_5_1 {
        actions = {
            read_value_5_1_act;
        }
    }
    @name(".read_value_5_2") table read_value_5_2 {
        actions = {
            read_value_5_2_act;
        }
    }
    @name(".read_value_5_3") table read_value_5_3 {
        actions = {
            read_value_5_3_act;
        }
    }
    @name(".read_value_5_4") table read_value_5_4 {
        actions = {
            read_value_5_4_act;
        }
    }
    @name(".remove_value_header_5") table remove_value_header_5 {
        actions = {
            remove_value_header_5_act;
        }
    }
    @name(".write_value_5_1") table write_value_5_1 {
        actions = {
            write_value_5_1_act;
        }
    }
    @name(".write_value_5_2") table write_value_5_2 {
        actions = {
            write_value_5_2_act;
        }
    }
    @name(".write_value_5_3") table write_value_5_3 {
        actions = {
            write_value_5_3_act;
        }
    }
    @name(".write_value_5_4") table write_value_5_4 {
        actions = {
            write_value_5_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_5.apply();
            read_value_5_1.apply();
            read_value_5_2.apply();
            read_value_5_3.apply();
            read_value_5_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_5_1.apply();
                write_value_5_2.apply();
                write_value_5_3.apply();
                write_value_5_4.apply();
                remove_value_header_5.apply();
            }
        }
    }
}

control process_value_6(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_6_1_reg") register<bit<32>>(32w128) value_6_1_reg;
    @name(".value_6_2_reg") register<bit<32>>(32w128) value_6_2_reg;
    @name(".value_6_3_reg") register<bit<32>>(32w128) value_6_3_reg;
    @name(".value_6_4_reg") register<bit<32>>(32w128) value_6_4_reg;
    @name(".add_value_header_6_act") action add_value_header_6_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_6.setValid();
    }
    @name(".read_value_6_1_act") action read_value_6_1_act() {
        value_6_1_reg.read(hdr.nc_value_6.value_6_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_6_2_act") action read_value_6_2_act() {
        value_6_2_reg.read(hdr.nc_value_6.value_6_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_6_3_act") action read_value_6_3_act() {
        value_6_3_reg.read(hdr.nc_value_6.value_6_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_6_4_act") action read_value_6_4_act() {
        value_6_4_reg.read(hdr.nc_value_6.value_6_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_6_act") action remove_value_header_6_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_6.setInvalid();
    }
    @name(".write_value_6_1_act") action write_value_6_1_act() {
        value_6_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_6.value_6_1);
    }
    @name(".write_value_6_2_act") action write_value_6_2_act() {
        value_6_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_6.value_6_2);
    }
    @name(".write_value_6_3_act") action write_value_6_3_act() {
        value_6_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_6.value_6_3);
    }
    @name(".write_value_6_4_act") action write_value_6_4_act() {
        value_6_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_6.value_6_4);
    }
    @name(".add_value_header_6") table add_value_header_6 {
        actions = {
            add_value_header_6_act;
        }
    }
    @name(".read_value_6_1") table read_value_6_1 {
        actions = {
            read_value_6_1_act;
        }
    }
    @name(".read_value_6_2") table read_value_6_2 {
        actions = {
            read_value_6_2_act;
        }
    }
    @name(".read_value_6_3") table read_value_6_3 {
        actions = {
            read_value_6_3_act;
        }
    }
    @name(".read_value_6_4") table read_value_6_4 {
        actions = {
            read_value_6_4_act;
        }
    }
    @name(".remove_value_header_6") table remove_value_header_6 {
        actions = {
            remove_value_header_6_act;
        }
    }
    @name(".write_value_6_1") table write_value_6_1 {
        actions = {
            write_value_6_1_act;
        }
    }
    @name(".write_value_6_2") table write_value_6_2 {
        actions = {
            write_value_6_2_act;
        }
    }
    @name(".write_value_6_3") table write_value_6_3 {
        actions = {
            write_value_6_3_act;
        }
    }
    @name(".write_value_6_4") table write_value_6_4 {
        actions = {
            write_value_6_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_6.apply();
            read_value_6_1.apply();
            read_value_6_2.apply();
            read_value_6_3.apply();
            read_value_6_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_6_1.apply();
                write_value_6_2.apply();
                write_value_6_3.apply();
                write_value_6_4.apply();
                remove_value_header_6.apply();
            }
        }
    }
}

control process_value_7(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_7_1_reg") register<bit<32>>(32w128) value_7_1_reg;
    @name(".value_7_2_reg") register<bit<32>>(32w128) value_7_2_reg;
    @name(".value_7_3_reg") register<bit<32>>(32w128) value_7_3_reg;
    @name(".value_7_4_reg") register<bit<32>>(32w128) value_7_4_reg;
    @name(".add_value_header_7_act") action add_value_header_7_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_7.setValid();
    }
    @name(".read_value_7_1_act") action read_value_7_1_act() {
        value_7_1_reg.read(hdr.nc_value_7.value_7_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_7_2_act") action read_value_7_2_act() {
        value_7_2_reg.read(hdr.nc_value_7.value_7_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_7_3_act") action read_value_7_3_act() {
        value_7_3_reg.read(hdr.nc_value_7.value_7_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_7_4_act") action read_value_7_4_act() {
        value_7_4_reg.read(hdr.nc_value_7.value_7_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_7_act") action remove_value_header_7_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_7.setInvalid();
    }
    @name(".write_value_7_1_act") action write_value_7_1_act() {
        value_7_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_7.value_7_1);
    }
    @name(".write_value_7_2_act") action write_value_7_2_act() {
        value_7_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_7.value_7_2);
    }
    @name(".write_value_7_3_act") action write_value_7_3_act() {
        value_7_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_7.value_7_3);
    }
    @name(".write_value_7_4_act") action write_value_7_4_act() {
        value_7_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_7.value_7_4);
    }
    @name(".add_value_header_7") table add_value_header_7 {
        actions = {
            add_value_header_7_act;
        }
    }
    @name(".read_value_7_1") table read_value_7_1 {
        actions = {
            read_value_7_1_act;
        }
    }
    @name(".read_value_7_2") table read_value_7_2 {
        actions = {
            read_value_7_2_act;
        }
    }
    @name(".read_value_7_3") table read_value_7_3 {
        actions = {
            read_value_7_3_act;
        }
    }
    @name(".read_value_7_4") table read_value_7_4 {
        actions = {
            read_value_7_4_act;
        }
    }
    @name(".remove_value_header_7") table remove_value_header_7 {
        actions = {
            remove_value_header_7_act;
        }
    }
    @name(".write_value_7_1") table write_value_7_1 {
        actions = {
            write_value_7_1_act;
        }
    }
    @name(".write_value_7_2") table write_value_7_2 {
        actions = {
            write_value_7_2_act;
        }
    }
    @name(".write_value_7_3") table write_value_7_3 {
        actions = {
            write_value_7_3_act;
        }
    }
    @name(".write_value_7_4") table write_value_7_4 {
        actions = {
            write_value_7_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_7.apply();
            read_value_7_1.apply();
            read_value_7_2.apply();
            read_value_7_3.apply();
            read_value_7_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_7_1.apply();
                write_value_7_2.apply();
                write_value_7_3.apply();
                write_value_7_4.apply();
                remove_value_header_7.apply();
            }
        }
    }
}

control process_value_8(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".value_8_1_reg") register<bit<32>>(32w128) value_8_1_reg;
    @name(".value_8_2_reg") register<bit<32>>(32w128) value_8_2_reg;
    @name(".value_8_3_reg") register<bit<32>>(32w128) value_8_3_reg;
    @name(".value_8_4_reg") register<bit<32>>(32w128) value_8_4_reg;
    @name(".add_value_header_8_act") action add_value_header_8_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
        hdr.nc_value_8.setValid();
    }
    @name(".read_value_8_1_act") action read_value_8_1_act() {
        value_8_1_reg.read(hdr.nc_value_8.value_8_1, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_8_2_act") action read_value_8_2_act() {
        value_8_2_reg.read(hdr.nc_value_8.value_8_2, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_8_3_act") action read_value_8_3_act() {
        value_8_3_reg.read(hdr.nc_value_8.value_8_3, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".read_value_8_4_act") action read_value_8_4_act() {
        value_8_4_reg.read(hdr.nc_value_8.value_8_4, (bit<32>)meta.nc_cache_md.cache_index);
    }
    @name(".remove_value_header_8_act") action remove_value_header_8_act() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - 16w16;
        hdr.udp.len = hdr.udp.len - 16w16;
        hdr.nc_value_8.setInvalid();
    }
    @name(".write_value_8_1_act") action write_value_8_1_act() {
        value_8_1_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_8.value_8_1);
    }
    @name(".write_value_8_2_act") action write_value_8_2_act() {
        value_8_2_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_8.value_8_2);
    }
    @name(".write_value_8_3_act") action write_value_8_3_act() {
        value_8_3_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_8.value_8_3);
    }
    @name(".write_value_8_4_act") action write_value_8_4_act() {
        value_8_4_reg.write((bit<32>)meta.nc_cache_md.cache_index, (bit<32>)hdr.nc_value_8.value_8_4);
    }
    @name(".add_value_header_8") table add_value_header_8 {
        actions = {
            add_value_header_8_act;
        }
    }
    @name(".read_value_8_1") table read_value_8_1 {
        actions = {
            read_value_8_1_act;
        }
    }
    @name(".read_value_8_2") table read_value_8_2 {
        actions = {
            read_value_8_2_act;
        }
    }
    @name(".read_value_8_3") table read_value_8_3 {
        actions = {
            read_value_8_3_act;
        }
    }
    @name(".read_value_8_4") table read_value_8_4 {
        actions = {
            read_value_8_4_act;
        }
    }
    @name(".remove_value_header_8") table remove_value_header_8 {
        actions = {
            remove_value_header_8_act;
        }
    }
    @name(".write_value_8_1") table write_value_8_1 {
        actions = {
            write_value_8_1_act;
        }
    }
    @name(".write_value_8_2") table write_value_8_2 {
        actions = {
            write_value_8_2_act;
        }
    }
    @name(".write_value_8_3") table write_value_8_3 {
        actions = {
            write_value_8_3_act;
        }
    }
    @name(".write_value_8_4") table write_value_8_4 {
        actions = {
            write_value_8_4_act;
        }
    }
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            add_value_header_8.apply();
            read_value_8_1.apply();
            read_value_8_2.apply();
            read_value_8_3.apply();
            read_value_8_4.apply();
        }
        else {
            if (hdr.nc_hdr.op == 8w9 && meta.nc_cache_md.cache_exist == 1w1) {
                write_value_8_1.apply();
                write_value_8_2.apply();
                write_value_8_3.apply();
                write_value_8_4.apply();
                remove_value_header_8.apply();
            }
        }
    }
}

control process_value(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".reply_read_hit_after_act") action reply_read_hit_after_act() {
        hdr.ipv4.srcAddr = meta.reply_read_hit_info_md.ipv4_dstAddr;
        hdr.ipv4.dstAddr = meta.reply_read_hit_info_md.ipv4_srcAddr;
        hdr.nc_hdr.op = 8w1;
    }
    @name(".reply_read_hit_before_act") action reply_read_hit_before_act() {
        meta.reply_read_hit_info_md.ipv4_srcAddr = hdr.ipv4.srcAddr;
        meta.reply_read_hit_info_md.ipv4_dstAddr = hdr.ipv4.dstAddr;
    }
    @name(".reply_read_hit_after") table reply_read_hit_after {
        actions = {
            reply_read_hit_after_act;
        }
    }
    @name(".reply_read_hit_before") table reply_read_hit_before {
        actions = {
            reply_read_hit_before_act;
        }
    }
    @name(".process_value_1") process_value_1() process_value_1_0;
    @name(".process_value_2") process_value_2() process_value_2_0;
    @name(".process_value_3") process_value_3() process_value_3_0;
    @name(".process_value_4") process_value_4() process_value_4_0;
    @name(".process_value_5") process_value_5() process_value_5_0;
    @name(".process_value_6") process_value_6() process_value_6_0;
    @name(".process_value_7") process_value_7() process_value_7_0;
    @name(".process_value_8") process_value_8() process_value_8_0;
    apply {
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            reply_read_hit_before.apply();
        }
        process_value_1_0.apply(hdr, meta, standard_metadata);
        process_value_2_0.apply(hdr, meta, standard_metadata);
        process_value_3_0.apply(hdr, meta, standard_metadata);
        process_value_4_0.apply(hdr, meta, standard_metadata);
        process_value_5_0.apply(hdr, meta, standard_metadata);
        process_value_6_0.apply(hdr, meta, standard_metadata);
        process_value_7_0.apply(hdr, meta, standard_metadata);
        process_value_8_0.apply(hdr, meta, standard_metadata);
        if (hdr.nc_hdr.op == 8w0 && meta.nc_cache_md.cache_valid == 1w1) {
            reply_read_hit_after.apply();
        }
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".set_egress") action set_egress(bit<9> egress_spec) {
        standard_metadata.egress_spec = egress_spec;
        hdr.ipv4.ttl = hdr.ipv4.ttl + 8w255;
    }
    @stage(11) @name(".ipv4_route") table ipv4_route {
        actions = {
            set_egress;
        }
        key = {
            hdr.ipv4.dstAddr: exact;
        }
        size = 8192;
    }
    @name(".process_cache") process_cache() process_cache_0;
    @name(".process_value") process_value() process_value_0;
    apply {
        process_cache_0.apply(hdr, meta, standard_metadata);
        process_value_0.apply(hdr, meta, standard_metadata);
        ipv4_route.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.nc_hdr);
        packet.emit(hdr.nc_load);
        packet.emit(hdr.nc_value_1);
        packet.emit(hdr.nc_value_2);
        packet.emit(hdr.nc_value_3);
        packet.emit(hdr.nc_value_4);
        packet.emit(hdr.nc_value_5);
        packet.emit(hdr.nc_value_6);
        packet.emit(hdr.nc_value_7);
        packet.emit(hdr.nc_value_8);
        packet.emit(hdr.tcp);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
        update_checksum(true, { hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv, hdr.ipv4.totalLen, hdr.ipv4.identification, hdr.ipv4.flags, hdr.ipv4.fragOffset, hdr.ipv4.ttl, hdr.ipv4.protocol, hdr.ipv4.srcAddr, hdr.ipv4.dstAddr }, hdr.ipv4.hdrChecksum, HashAlgorithm.csum16);
        update_checksum_with_payload(true, { hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, 8w0, hdr.ipv4.protocol, hdr.udp.len, hdr.udp.srcPort, hdr.udp.dstPort, hdr.udp.len }, hdr.udp.checksum, HashAlgorithm.csum16);
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

