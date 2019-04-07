/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/* Manually translated into P4-16 */

#define ETHERTYPE_IPV4 0x0800


/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/
header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

/*struct metadata {
    /* empty */
//}


struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
}

struct tracking_metadata_t {
    bit<32> mKeyInTable;
    bit<32> mCountInTable;
    bit<5> mIndex;
    bit<1> mValid;
    bit<32> mKeyCarried;
    bit<32> mCountCarried;
    bit<32> mDiff;
    bit<32> nhop_ipv4;
}


/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout tracking_metadata_t hh_meta,
                inout standard_metadata_t standard_metadata) {
    
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            ETHERTYPE_IPV4 : parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }

}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout tracking_metadata_t hh_meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout tracking_metadata_t hh_meta,
                  inout standard_metadata_t standard_metadata) {

    register<bit<32>>(32) flow_tracker_stage1;
    register<bit<32>>(32) packet_counter_stage1;
    register<bit<1>>(32) valid_bit_stage1;

    register<bit<32>>(32) flow_tracker_stage2;
    register<bit<32>>(32) packet_counter_stage2;
    register<bit<1>>(32) valid_bit_stage2;

    register<bit<32>>(16) drops_register;
    register<bit<1>>(16) drops_register_enabled;

    action do_stage1() {
        // first table stage
        hh_meta.mKeyCarried = hdr.ipv4.srcAddr;
        hh_meta.mCountCarried = 0;

        // hash using my custom function 
        hash(hh_meta.mIndex, HashAlgorithm.csum16, (bit<16>)0, {hh_meta.mKeyCarried}, (bit<32>)32);

        // read the key and value at that location
        // hh_meta.mKeyInTable = flow_tracker_stage1[hh_meta.mIndex];
        flow_tracker_stage1.read(hh_meta.mKeyInTable, (bit<32>)hh_meta.mIndex);
        // hh_meta.mCountInTable = packet_counter_stage1[hh_meta.mIndex];
        packet_counter_stage1.read(hh_meta.mCountInTable, (bit<32>)hh_meta.mIndex);
        // hh_meta.mValid = valid_bit_stage1[hh_meta.mIndex];
        valid_bit_stage1.read(hh_meta.mValid, (bit<32>)hh_meta.mIndex);

        // check if location is empty or has a differentkey in there
        hh_meta.mKeyInTable = (hh_meta.mValid == 0) ? hh_meta.mKeyCarried : hh_meta.mKeyInTable;
        hh_meta.mDiff = (hh_meta.mValid == 0) ? 0 : hh_meta.mKeyInTable - hh_meta.mKeyCarried;

        // update hash table
        // flow_tracker_stage1[hh_meta.mIndex] = hdr.ipv4.srcAddr;
        flow_tracker_stage1.write((bit<32>)hh_meta.mIndex, hdr.ipv4.srcAddr);
        // packet_counter_stage1[hh_meta.mIndex] = ((hh_meta.mDiff == 0)? hh_meta.mCountInTable + 1 : 1);
        packet_counter_stage1.write((bit<32>)hh_meta.mIndex, ((hh_meta.mDiff == 0)? hh_meta.mCountInTable + 1 : 1));
        // valid_bit_stage1[hh_meta.mIndex] = 1;
        valid_bit_stage1.write((bit<32>)hh_meta.mIndex, 1);

        // update metadata carried to the next table stage
        hh_meta.mKeyCarried = ((hh_meta.mDiff == 0) ? 0:
        hh_meta.mKeyInTable);
        hh_meta.mCountCarried = ((hh_meta.mDiff == 0) ? 0:
        hh_meta.mCountInTable); 
    }

    action do_stage2() {
        // hash using my custom function 
        hash(hh_meta.mIndex, HashAlgorithm.csum16, (bit<16>)0, {hh_meta.mKeyCarried}, (bit<32>)32);

        // read the key and value at that location
        flow_tracker_stage2.read(hh_meta.mKeyInTable, (bit<32>)hh_meta.mIndex);
        packet_counter_stage2.read(hh_meta.mCountInTable, (bit<32>)hh_meta.mIndex);
        valid_bit_stage2.read(hh_meta.mValid, (bit<32>)hh_meta.mIndex);

        // check if location is empty or has a differentkey in there
        hh_meta.mKeyInTable = (hh_meta.mValid == 0)? hh_meta.mKeyCarried : hh_meta.mKeyInTable;
        hh_meta.mDiff = (hh_meta.mValid == 0)? 0 : hh_meta.mKeyInTable - hh_meta.mKeyCarried;

        // update hash table
        flow_tracker_stage2.write((bit<32>)hh_meta.mIndex, ((hh_meta.mDiff == 0)?
        hh_meta.mKeyInTable : ((hh_meta.mCountInTable <
        hh_meta.mCountCarried) ? hh_meta.mKeyCarried :
        hh_meta.mKeyInTable)));
        packet_counter_stage2.write((bit<32>)hh_meta.mIndex, ((hh_meta.mDiff == 0)?
        hh_meta.mCountInTable + hh_meta.mCountCarried :
        ((hh_meta.mCountInTable < hh_meta.mCountCarried) ?
        hh_meta.mCountCarried : hh_meta.mCountInTable)));
        valid_bit_stage2.write((bit<32>)hh_meta.mIndex, ((hh_meta.mValid == 0) ?
        ((hh_meta.mKeyCarried == 0) ? (bit<1>)0 : 1) : (bit<1>)1));

        // update metadata carried to the next table stage
        hh_meta.mKeyCarried = ((hh_meta.mDiff == 0) ? 0:
        hh_meta.mKeyInTable);
        hh_meta.mCountCarried = ((hh_meta.mDiff == 0) ? 0:
        hh_meta.mCountInTable); 
    }

    action _drop() {
        mark_to_drop();
    }

    action do_drop_expired() {
        bit<32> value_tmp;
        bit<1> valid_tmp;
        drops_register.read(value_tmp, (bit<32>)0);
        drops_register_enabled.read(valid_tmp, (bit<32>)0);
        value_tmp = value_tmp + ((valid_tmp == 1) ? (bit<32>)1 : 0);
        drops_register.write((bit<32>)0, value_tmp);
        _drop();
    }

    action set_nhop(bit<32> nhop_ipv4, bit<9> port) {
        hh_meta.nhop_ipv4 = nhop_ipv4;
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    action set_dmac(bit<48> dmac) {
        hdr.ethernet.dstAddr = dmac;
        // modify_field still valid
        // modify_field(ethernet.dstAddr, dmac);
    }

    table tbl_do_stage1 {
        actions = {do_stage1;}
        default_action = do_stage1();
    }

    table tbl_do_stage2 {
        actions = {do_stage2;}
        default_action = do_stage2();
    }

    table tbl_drop_expired {
        actions = {do_drop_expired;}
        default_action = do_drop_expired();
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr : lpm;
        }
        actions = {
            set_nhop;
            _drop;
        }
        size = 512;
    }

    table forward {
        key = {
            hh_meta.nhop_ipv4 : exact;
        }
        actions = {
            set_dmac;
            _drop;
        }
        size = 512;
    }
     
    apply {
        tbl_do_stage1.apply();
        tbl_do_stage2.apply();

        if (hdr.ipv4.isValid()) {
            if (hdr.ipv4.ttl > 1) {
                ipv4_lpm.apply();
                forward.apply();
            } else {
                tbl_drop_expired.apply();
            }
        }
    }

}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout tracking_metadata_t hh_meta,
                 inout standard_metadata_t standard_metadata) {

    action _drop() {
        mark_to_drop();
    }

    action rewrite_mac(bit<48> smac) {
        hdr.ethernet.srcAddr = smac;
    }

    table send_frame {
        key = {
            standard_metadata.egress_port: exact;
        }
        actions = {
            rewrite_mac;
            _drop;
        }
        size = 256;
    }

    apply {
        send_frame.apply();
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout tracking_metadata_t hh_meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;