/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<5>  IPV4_OPTION_STAG = 31;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header ipv4_option_t {
    bit<1> copyFlag;
    bit<2> optClass;
    bit<5> option;
    bit<8> optionLength;
}

header stag_t {
    // The stag holds the original source port color
    bit<8>  source_color;
}

header local_md_t {
    bit<8>  src_port_color;
    bit<8>  dst_port_color;
    bit<1>  toLocal;
}

struct metadata {
    local_md_t  local_md;
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    ipv4_option_t  ipv4_option;
    stag_t        stag;
}

error { IPHeaderTooShort }

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        verify(hdr.ipv4.ihl >= 5, error.IPHeaderTooShort);
        transition select(hdr.ipv4.ihl) {
            5             : accept;
            default       : parse_ipv4_option;
        }
    }

    state parse_ipv4_option {
        packet.extract(hdr.ipv4_option);
        transition select(hdr.ipv4_option.option) {
            IPV4_OPTION_STAG: parse_stag;
            default: accept;
        }
    }

    state parse_stag {
        packet.extract(hdr.stag);
        meta.local_md.src_port_color = hdr.stag.source_color;
        transition accept;
    }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop();
    }
    
    action set_source_color(bit<8> color){
      meta.local_md.src_port_color = color;
    }

    table get_source_color {
      key = {standard_metadata.ingress_port : exact;}
      actions = {set_source_color;}
    }
    action set_local_dest(bit<9> egr_port, bit<8> color){
      standard_metadata.egress_spec = egr_port;
      meta.local_md.dst_port_color = color;
      hdr.stag.setInvalid();
    } 

    action set_remote_dest(bit<9> egr_port){
      standard_metadata.egress_spec = egr_port;
      // configure hdr.ipv4.option_stag
      hdr.ipv4_option.setValid();
      hdr.ipv4_option.copyFlag     = 1;
      hdr.ipv4_option.optClass     = 2;
      hdr.ipv4_option.option       = IPV4_OPTION_STAG;
      hdr.ipv4_option.optionLength = 4;  /* sizeof(ipv4_option) + sizeof(stag) */
      hdr.ipv4.ihl = hdr.ipv4.ihl + 1;
      
      // configure hdr.stag
      hdr.stag.setValid();
      hdr.stag.source_color = meta.local_md.src_port_color;
    }

    action core_pass_through(bit<9> egr_port){
      standard_metadata.egress_spec = egr_port;
    }

    table forward {
      key = {hdr.ipv4.dstAddr: ternary;}
      actions = { set_local_dest; set_remote_dest; core_pass_through; NoAction;}
      size = 1024;
      default_action = NoAction;
    }    

    @assert("if(standard_metadata.ingress_port == 1 && hdr.ipv4.dstAddr == 167772162, !forward)")
    table color_check {
      key = {
        meta.local_md.dst_port_color: exact;
        meta.local_md.src_port_color: exact;
      }
      actions = { drop; NoAction; }
      size = 1024;
      default_action = drop;
    }
  
    apply {
        if (!hdr.stag.isValid()) { // stag header not valid -> packet going from local 2 core
          get_source_color.apply(); // register src port color 
        }

        switch(forward.apply().action_run){
          set_local_dest: { color_check.apply(); }
	}
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/
control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
		table place_holder_table {
				actions = {
					NoAction;
        }
        size = 2;
        default_action = NoAction();
		}
    apply {
        place_holder_table.apply();
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/


control computeChecksum(inout headers  hdr, inout metadata meta)
{    
    apply {
        
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    
    apply {
       
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.ipv4_option);
        packet.emit(hdr.stag);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
