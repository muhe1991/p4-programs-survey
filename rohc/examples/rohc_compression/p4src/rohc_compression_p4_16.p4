/*
 * Jeferson Santiago da Silva (eng.jefersonsantiago@gmail.com)
 * Laurent Olivier Chiquette (l.o.chiquette@gmail.com)
 */

#include <core.p4>
#include <v1model.p4>

#define USE_NATIVE_PRIMITIVE 0
#define USE_RECIRCULATE 1

extern ExternRohcCompressor {
	ExternRohcCompressor(bool verbose);
	void rohc_comp_header();
}

extern ExternRohcDecompressor {
	ExternRohcDecompressor(bit<1> verbose);
	void rohc_decomp_header();
}

extern ext_type {
   	ext_type(bit<1> ext_attr_a, bit<1> ext_attr_b); 
    void ext_method(in bit<9> p1, in bit<9> p2, out bit<9> p3);
}

header ethernet_t {
        bit<48> dstAddr;
        bit<48> srcAddr;
        bit<16> etherType;
}

// Field are multiple of byte to easy the data manipulation
// IP header
header ipv4_t {
        bit<8>  version_ihl;      // [7..4] version, [3..0] ihl
        bit<8>  diffserv;
        bit<16> totalLen;
        bit<16> identification;
        bit<16> flags_fragOffset; // [15..13] flags, fragOffset [12..0]
        bit<8>  ttl;
        bit<8>  protocol;
        bit<16> hdrChecksum;
        bit<32> srcAddr;
        bit<32> dstAddr;
}

// UDP header
header udp_t {
        bit<16> srcPort;
        bit<16> dstPort;
        bit<16> hdrLength;
        bit<16> chksum;
}

// RTP header
header rtp_t {
		bit<8>      version_pad_ext_nCRSC; // [7..6] version, [5] pad, [4] ext, [3..0] nCRSC
	    bit<8>      marker_payloadType;    // [7] marker, [6..0] payloadType
	    bit<16>     sequenceNumber;
	    bit<32>     timestamp;
	    bit<32>     SSRC;
}

// List of all recognized headers
struct parsed_packet {
    ethernet_t ethernet;
    ipv4_t     ipv4;
    udp_t      udp;
    rtp_t      rtp;
}

struct intrinsic_metadata_t {
	bit<16>   recirculate_flag;
	bit<16>   modify_and_resubmit_flag;
}

struct local_metadata_t {
	bit<9>   in_par_a;
	bit<9>   in_par_b;
	bit<9>   out_par;
}

struct metadata {
	@metadata @name("intrinsic_metadata")
	intrinsic_metadata_t intrinsic_metadata;
	local_metadata_t local_metadata;
}

parser TopParser(packet_in b,
				out parsed_packet p,
				inout metadata meta,
				inout standard_metadata_t standard_metadata) {

    state start {
        b.extract(p.ethernet);
        transition select(p.ethernet.etherType) {
            0x0800 : parse_ipv4;
	default: accept;
            // no default rule: all other packets rejected
        }
    }

    state parse_ipv4 {
        b.extract(p.ipv4);
        transition select(p.ipv4.protocol) {
            0x11      : parse_udp;
	default   : accept;
	}
	}

    state parse_udp {
        b.extract(p.udp);
        transition select(p.udp.dstPort) {
	1234      : parse_rtp;
	1235      : parse_rtp;
	5004      : parse_rtp;
	5005      : parse_rtp;
	default   : accept;
	}
	}

	state parse_rtp {
	    b.extract(p.rtp);
        transition accept;
	}
}

control ingress(inout parsed_packet headers,
				inout metadata meta,
                inout standard_metadata_t standard_metadata) {

	@userextern @name("my_rohc_decomp")
	ExternRohcDecompressor(0x1) my_rohc_decomp;
	action _nop() {
	}

	action set_port(bit<9> port) {
	    standard_metadata.egress_port = port;
	#if USE_RECIRCULATE
	    meta.intrinsic_metadata.recirculate_flag = 0;
	#else
	    meta.intrinsic_metadata.modify_and_resubmit_flag = 0;
	#endif
	}

	action _resubmit() {
	#if USE_RECIRCULATE
	    //recirculate(intrinsic_metadata.recirculate_flag);
	    recirculate({meta.intrinsic_metadata, standard_metadata});
	#else
	    modify_and_resubmit(intrinsic_metadata.modify_and_resubmit_flag);
	#endif
	}

	action _decompress() {
	    headers.ethernet.etherType = 0x0800;
	#if USE_NATIVE_PRIMITIVE
	    rohc_decomp_header();
	#else
	    my_rohc_decomp.rohc_decomp_header();
	#endif
	#if USE_RECIRCULATE
	    meta.intrinsic_metadata.recirculate_flag = 1;
	#else
	    meta.intrinsic_metadata.modify_and_resubmit_flag = 1;
	#endif
	}

	table t_ingress_1 {
	    key = {
	        standard_metadata.ingress_port : exact;
	    }
	    actions = {
	        _nop; set_port;
	    }
	    size = 2;
        default_action = _nop;
	}

	table t_ingress_rohc_decomp {
	    key = { headers.ethernet.etherType : exact;
	    }
	    actions = {
	        _nop; _decompress;
	    }
	    size = 2;
        default_action = _nop;
	}

	table t_resub {
	    key = {
	#if USE_RECIRCULATE
	        meta.intrinsic_metadata.recirculate_flag : exact;
	#else
	        meta.intrinsic_metadata.modify_and_resubmit_flag : exact;
	#endif
	    }
	    actions  = {
	        _nop; _resubmit;
	    }
	    size = 2;
        default_action = _nop;
	}

	apply {
		//t_ingress_1.apply();
		t_ingress_rohc_decomp.apply();
		#if USE_RECIRCULATE
		    if(meta.intrinsic_metadata.recirculate_flag == 1) {
		#else
		    if(meta.intrinsic_metadata.modify_and_resubmit_flag == 1) {
		#endif
				t_resub.apply();
		}
	}
}

control egress (inout parsed_packet headers,
				inout metadata meta,
                inout standard_metadata_t standard_metadata) {
	ExternRohcCompressor(false) my_rohc_comp;
	//ext_type(0x1,0x1) my_ext_inst;

	action _nop() {}

	action _compress () {
	#if USE_NATIVE_PRIMITIVE
	    rohc_comp_header();
	#else
	    my_rohc_comp.rohc_comp_header();
	#endif
	    headers.ethernet.etherType = 0xDD00;
	}

	table t_compress {
	   key = {
	        standard_metadata.egress_port : exact;
	    }
	    actions = {
	        _nop; _compress;
	    }
	    size = 2;
        default_action = _nop;

	}
	apply {
	#if USE_RECIRCULATE
	    if(meta.intrinsic_metadata.recirculate_flag != 1) {
	#else
	    if(meta.intrinsic_metadata.modify_and_resubmit_flag != 1) {
	#endif
			//t_compress.apply();
			_compress ();
		    standard_metadata.egress_port = 3;
		    meta.local_metadata.in_par_a = 1;
		    meta.local_metadata.in_par_b = 2;
			//my_ext_inst.ext_method(	meta.local_metadata.in_par_a,
			//						meta.local_metadata.in_par_b,
			//						meta.local_metadata.out_par);
		}
	}
}

control ver_chsum(in parsed_packet p, inout metadata meta) {
	apply {}
}

control up_cksum(inout parsed_packet p, inout metadata meta) {
	apply {}
}

// deparser section
control deparser(packet_out b, in parsed_packet p) {
    apply {
        b.emit(p.ethernet);
    }
}

V1Switch(TopParser(),
	ver_chsum(),
	ingress(),
	egress(),
	up_cksum(),
	deparser()) main;
