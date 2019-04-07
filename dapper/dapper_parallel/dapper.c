#define BITSLICE(x, a, b) ((x) >> (b)) & ((1 << ((a)-(b)+1)) - 1)
#include<stdio.h>
#include<stdint.h>
#include<stdlib.h>
#include<assert.h>

int symbol;
int assert_forward = 1;
int action_run;

void end_assertions();


int hdr_tcp_ack_453638;
int traverse_453638 = 0;

 int meta_stats_metadata_dupack_le_3_454027;
int traverse_454027 = 0;

 int hdr_ipv4_ttl_eq_0_455545;

uint64_t constant_hdr_tcp_dstPort_455552;

uint64_t constant_hdr_tcp_seqNo_455559;

uint64_t constant_hdr_tcp_ackNo_455566;

uint64_t constant_hdr_tcp_dataOffset_455573;

uint64_t constant_hdr_tcp_res_455580;

uint64_t constant_hdr_tcp_ecn_455587;

uint64_t constant_hdr_tcp_urg_455594;

uint64_t constant_hdr_tcp_ack_455601;

uint64_t constant_hdr_tcp_push_455608;

uint64_t constant_hdr_tcp_rst_455615;

uint64_t constant_hdr_tcp_syn_455622;

uint64_t constant_hdr_tcp_fin_455629;

uint64_t constant_hdr_tcp_window_455636;

uint64_t constant_hdr_tcp_checksum_455643;

uint64_t constant_hdr_tcp_urgentPtr_455650;

void lookup_reverse_455435();
void update_flow_dupack_0_453843();
void NoAction_30_453274();
void _drop_4_454454();
void set_nhop_0_454574();
void accept();
void _drop_1_454438();
void flow_retx_3dupack_455113();
void NoAction_28_453272();
void lookup_flow_map_0_454610();
void record_IP_0_454487();
void set_dmac_0_454420();
void NoAction_20_453264();
void NoAction_26_453270();
void sample_rtt_sent_455503();
void parse_ethernet();
void parse_sack();
void NoAction_29_453273();
void parse_tcp();
void lookup_455401();
void update_flow_rcvd_0_453896();
void debug_454943();
void increase_mincwnd_0_454461();
void start();
void send_frame_453170();
void lookup_flow_map_reverse_0_454672();
void _drop_0_453154();
void reject();
void direction_454977();
void NoAction_23_453267();
void sample_new_rtt_0_454900();
void update_flow_retx_timeout_0_454141();
void NoAction_0_453126();
void NoAction_31_453275();
void use_sample_rtt_0_459912();
void parse_mss();
void parse_ts();
void use_sample_rtt_first_0_458416();
void ipv4_lpm_455342();
void NoAction_22_453266();
void parse_end();
void NoAction_19_453263();
void init_455308();
void increase_cwnd_455274();
void forward_455215();
void parse_ipv4();
void flow_sent_455181();
void NoAction_21_453265();
void get_sender_IP_0_453622();
void flow_dupack_455045();
void rewrite_mac_0_453136();
void flow_retx_timeout_455147();
void NoAction_27_453271();
void NoAction_25_453269();
void flow_rcvd_455079();
void NoAction_24_453268();
void NoAction_32_453276();
void save_source_IP_0_453564();
void parse_tcp_options();
void NoAction_1_453262();
void parse_nop();
void parse_wscale();
void update_flow_retx_3dupack_0_454011();
void first_rtt_sample_455011();
void update_flow_sent_0_454233();
void sample_rtt_rcvd_455469();
void NoAction_33_453277();

typedef struct {
	uint32_t ingress_port : 9;
	uint32_t egress_spec : 9;
	uint32_t egress_port : 9;
	uint32_t clone_spec : 32;
	uint32_t instance_type : 32;
	uint8_t drop : 1;
	uint32_t recirculate_port : 16;
	uint32_t packet_length : 32;
	uint32_t enq_timestamp : 32;
	uint32_t enq_qdepth : 19;
	uint32_t deq_timedelta : 32;
	uint32_t deq_qdepth : 19;
	uint64_t ingress_global_timestamp : 48;
	uint32_t lf_field_list : 32;
	uint32_t mcast_grp : 16;
	uint8_t resubmit_flag : 1;
	uint32_t egress_rid : 16;
	uint8_t checksum_error : 1;
} standard_metadata_t;

void mark_to_drop() {
	assert_forward = 0;
	end_assertions();
	exit(0);
}

typedef struct {
	uint64_t ingress_global_timestamp : 48;
	uint32_t lf_field_list : 32;
	uint32_t mcast_grp : 16;
	uint32_t egress_rid : 16;
} intrinsic_metadata_t;

typedef struct {
	uint8_t parse_tcp_options_counter : 8;
} my_metadata_t;

typedef struct {
	uint32_t nhop_ipv4 : 32;
} routing_metadata_t;

typedef struct {
	uint32_t dummy : 32;
	uint32_t dummy2 : 32;
	uint8_t flow_map_index : 2;
	uint32_t senderIP : 32;
	uint32_t seqNo : 32;
	uint32_t ackNo : 32;
	uint32_t sample_rtt_seq : 32;
	uint32_t rtt_samples : 32;
	uint32_t mincwnd : 32;
	uint32_t dupack : 32;
} stats_metadata_t;

typedef struct {
	uint8_t isValid : 1;
	uint64_t dstAddr : 48;
	uint64_t srcAddr : 48;
	uint32_t etherType : 16;
} ethernet_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t version : 4;
	uint8_t ihl : 4;
	uint8_t diffserv : 8;
	uint32_t totalLen : 16;
	uint32_t identification : 16;
	uint8_t flags : 3;
	uint32_t fragOffset : 13;
	uint8_t ttl : 8;
	uint8_t protocol : 8;
	uint32_t hdrChecksum : 16;
	uint32_t srcAddr : 32;
	uint32_t dstAddr : 32;
} ipv4_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t kind : 8;
} options_end_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t kind : 8;
	uint8_t len : 8;
	uint32_t MSS : 16;
} options_mss_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t kind : 8;
	uint8_t len : 8;
} options_sack_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t kind : 8;
	uint8_t len : 8;
	uint64_t ttee : 64;
} options_ts_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t kind : 8;
	uint8_t len : 8;
	uint8_t wscale : 8;
} options_wscale_t;

typedef struct {
	uint8_t isValid : 1;
	uint32_t srcPort : 16;
	uint32_t dstPort : 16;
	uint32_t seqNo : 32;
	uint32_t ackNo : 32;
	uint8_t dataOffset : 4;
	uint8_t res : 3;
	uint8_t ecn : 3;
	uint8_t urg : 1;
	uint8_t ack : 1;
	uint8_t push : 1;
	uint8_t rst : 1;
	uint8_t syn : 1;
	uint8_t fin : 1;
	uint32_t window : 16;
	uint32_t checksum : 16;
	uint32_t urgentPtr : 16;
} tcp_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t kind : 8;
} options_nop_t;

typedef struct {
	intrinsic_metadata_t intrinsic_metadata;
	my_metadata_t my_metadata;
	routing_metadata_t routing_metadata;
	stats_metadata_t stats_metadata;
} metadata;

typedef struct {
	ethernet_t ethernet;
	ipv4_t ipv4;
	options_end_t options_end;
	options_mss_t options_mss;
	options_sack_t options_sack;
	options_ts_t options_ts;
	options_wscale_t options_wscale;
	tcp_t tcp;
	int options_nop_index;
	options_nop_t options_nop[3];
} headers;

headers hdr;
metadata meta;
standard_metadata_t standard_metadata;

uint8_t tmp_0;

void parse_end() {
	//Extract hdr.options_end
	hdr.options_end.isValid = 1;
	meta.my_metadata.parse_tcp_options_counter = meta.my_metadata.parse_tcp_options_counter + 255;
	parse_tcp_options();
}


void parse_ethernet() {
	//Extract hdr.ethernet
	hdr.ethernet.isValid = 1;
	if((hdr.ethernet.etherType == 2048)){
		parse_ipv4();
	} else {
		accept();
	}
}


void parse_ipv4() {
	//Extract hdr.ipv4
	hdr.ipv4.isValid = 1;
	if((hdr.ipv4.protocol == 6)){
		parse_tcp();
	} else {
		accept();
	}
}


void parse_mss() {
	//Extract hdr.options_mss
	hdr.options_mss.isValid = 1;
	meta.my_metadata.parse_tcp_options_counter = meta.my_metadata.parse_tcp_options_counter + 252;
	parse_tcp_options();
}


void parse_nop() {
	//Extract hdr.options_nop.next
	hdr.options_nop[hdr.options_nop_index].isValid = 1;
	hdr.options_nop_index++;
	meta.my_metadata.parse_tcp_options_counter = meta.my_metadata.parse_tcp_options_counter + 255;
	parse_tcp_options();
}


void parse_sack() {
	//Extract hdr.options_sack
	hdr.options_sack.isValid = 1;
	meta.my_metadata.parse_tcp_options_counter = meta.my_metadata.parse_tcp_options_counter + 254;
	parse_tcp_options();
}


void parse_tcp() {
	//Extract hdr.tcp
	hdr.tcp.isValid = 1;
	meta.my_metadata.parse_tcp_options_counter = (uint8_t) hdr.tcp.dataOffset << 2 + 12;
	if((hdr.tcp.syn == 1)){
		parse_tcp_options();
	} else {
		accept();
	}
}


void parse_tcp_options() {
		klee_make_symbolic(&tmp_0, sizeof(tmp_0), "tmp_0");

	if(((meta.my_metadata.parse_tcp_options_counter & 255) == (0 & 255)) && ((BITSLICE(tmp_0, 7, 0) & 0) == (0 & 0))){
		accept();
	} else if(((meta.my_metadata.parse_tcp_options_counter & 0) == (0 & 0)) && ((BITSLICE(tmp_0, 7, 0) & 255) == (0 & 255))){
		parse_end();
	} else if(((meta.my_metadata.parse_tcp_options_counter & 0) == (0 & 0)) && ((BITSLICE(tmp_0, 7, 0) & 255) == (1 & 255))){
		parse_nop();
	} else if(((meta.my_metadata.parse_tcp_options_counter & 0) == (0 & 0)) && ((BITSLICE(tmp_0, 7, 0) & 255) == (2 & 255))){
		parse_mss();
	} else if(((meta.my_metadata.parse_tcp_options_counter & 0) == (0 & 0)) && ((BITSLICE(tmp_0, 7, 0) & 255) == (3 & 255))){
		parse_wscale();
	} else if(((meta.my_metadata.parse_tcp_options_counter & 0) == (0 & 0)) && ((BITSLICE(tmp_0, 7, 0) & 255) == (4 & 255))){
		parse_sack();
	} else if(((meta.my_metadata.parse_tcp_options_counter & 0) == (0 & 0)) && ((BITSLICE(tmp_0, 7, 0) & 255) == (8 & 255))){
		parse_ts();
	}
}


void parse_ts() {
	//Extract hdr.options_ts
	hdr.options_ts.isValid = 1;
	meta.my_metadata.parse_tcp_options_counter = meta.my_metadata.parse_tcp_options_counter + 246;
	parse_tcp_options();
}


void parse_wscale() {
	//Extract hdr.options_wscale
	hdr.options_wscale.isValid = 1;
	meta.my_metadata.parse_tcp_options_counter = meta.my_metadata.parse_tcp_options_counter + 253;
	parse_tcp_options();
}


void start() {
	parse_ethernet();
}


void accept() {
	
}


void reject() {
	assert_forward = 0;
	end_assertions();
	exit(0);
}


void ParserImpl() {
	klee_make_symbolic(&hdr, sizeof(hdr), "hdr");
	klee_make_symbolic(&meta, sizeof(meta), "meta");
	klee_make_symbolic(&standard_metadata, sizeof(standard_metadata), "standard_metadata");
	start();
}

//Control

void egress() {
	send_frame_453170();
}

// Action
void NoAction_0_453126() {
	action_run = 453126;
	
}


// Action
void rewrite_mac_0_453136() {
	action_run = 453136;
	uint64_t smac;
	klee_make_symbolic(&smac, sizeof(smac), "smac");
	hdr.ethernet.srcAddr = smac;

}


// Action
void _drop_0_453154() {
	action_run = 453154;
		mark_to_drop();

}


//Table
void send_frame_453170() {
	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
        //switch(klee_int("symbol")){
		case 0: rewrite_mac_0_453136(); break;
		case 1: _drop_0_453154(); break;
		default: NoAction_0_453126(); break;
	}
	// keys: standard_metadata.egress_port:exact
	// size 256
	// default_action NoAction_0();

}



typedef struct {
	uint32_t field : 32;
	uint32_t field_0 : 32;
	uint8_t field_1 : 8;
	uint32_t field_2 : 16;
	uint32_t field_3 : 16;
} tuple_0;

//Control

void ingress() {
	hdr_ipv4_ttl_eq_0_455545 = (hdr.ipv4.ttl  ==  0);
	
	constant_hdr_tcp_dstPort_455552 = hdr.tcp.dstPort;
	constant_hdr_tcp_seqNo_455559 = hdr.tcp.seqNo;
	constant_hdr_tcp_ackNo_455566 = hdr.tcp.ackNo;
	constant_hdr_tcp_dataOffset_455573 = hdr.tcp.dataOffset;
	constant_hdr_tcp_res_455580 = hdr.tcp.res;
	constant_hdr_tcp_ecn_455587 = hdr.tcp.ecn;
	constant_hdr_tcp_urg_455594 = hdr.tcp.urg;
	constant_hdr_tcp_ack_455601 = hdr.tcp.ack;
	constant_hdr_tcp_push_455608 = hdr.tcp.push;
	constant_hdr_tcp_rst_455615 = hdr.tcp.rst;
	constant_hdr_tcp_syn_455622 = hdr.tcp.syn;
	constant_hdr_tcp_fin_455629 = hdr.tcp.fin;
	constant_hdr_tcp_window_455636 = hdr.tcp.window;
	constant_hdr_tcp_checksum_455643 = hdr.tcp.checksum;
	constant_hdr_tcp_urgentPtr_455650 = hdr.tcp.urgentPtr;
	if((hdr.ipv4.protocol == 6)) {
		if(hdr.ipv4.srcAddr > hdr.ipv4.dstAddr) {
	lookup_455401();
} else {
	lookup_reverse_455435();
}
	if((hdr.tcp.syn == 1) && (hdr.tcp.ack == 0)) {
	init_455308();
} else {
	direction_454977();
}
	if((hdr.ipv4.srcAddr == meta.stats_metadata.senderIP)) {
	if(hdr.tcp.seqNo > meta.stats_metadata.seqNo) {
		flow_sent_455181();
	if((meta.stats_metadata.sample_rtt_seq == 0)) {
	sample_rtt_sent_455503();
}
	if(meta.stats_metadata.dummy > meta.stats_metadata.mincwnd) {
	increase_cwnd_455274();
}

} else {
	if((meta.stats_metadata.dupack == 3)) {
	flow_retx_3dupack_455113();
} else {
	flow_retx_timeout_455147();
}
}
} else {
	if((hdr.ipv4.dstAddr == meta.stats_metadata.senderIP)) {
	if(hdr.tcp.ackNo > meta.stats_metadata.ackNo) {
		flow_rcvd_455079();
	if(hdr.tcp.ackNo >= meta.stats_metadata.sample_rtt_seq && meta.stats_metadata.sample_rtt_seq > 0) {
	if((meta.stats_metadata.rtt_samples == 0)) {
	first_rtt_sample_455011();
} else {
	sample_rtt_rcvd_455469();
}
}

} else {
	flow_dupack_455045();
}
} else {
	debug_454943();
}
}

}
	ipv4_lpm_455342();
	forward_455215();
}

// Action
void NoAction_1_453262() {
	action_run = 453262;
	
}


// Action
void NoAction_19_453263() {
	action_run = 453263;
	
}


// Action
void NoAction_20_453264() {
	action_run = 453264;
	
}


// Action
void NoAction_21_453265() {
	action_run = 453265;
	
}


// Action
void NoAction_22_453266() {
	action_run = 453266;
	
}


// Action
void NoAction_23_453267() {
	action_run = 453267;
	
}


// Action
void NoAction_24_453268() {
	action_run = 453268;
	
}


// Action
void NoAction_25_453269() {
	action_run = 453269;
	
}


// Action
void NoAction_26_453270() {
	action_run = 453270;
	
}


// Action
void NoAction_27_453271() {
	action_run = 453271;
	
}


// Action
void NoAction_28_453272() {
	action_run = 453272;
	
}


// Action
void NoAction_29_453273() {
	action_run = 453273;
	
}


// Action
void NoAction_30_453274() {
	action_run = 453274;
	
}


// Action
void NoAction_31_453275() {
	action_run = 453275;
	
}


// Action
void NoAction_32_453276() {
	action_run = 453276;
	
}


// Action
void NoAction_33_453277() {
	action_run = 453277;
	
}


// Action
void save_source_IP_0_453564() {
	action_run = 453564;
	
}


// Action
void get_sender_IP_0_453622() {
	action_run = 453622;
		hdr_tcp_ack_453638 = (hdr.tcp.ack == 1);
	traverse_453638 = 1;
	
	uint64_t t84710467_540e_4c78_b9f4_a4a8cde883cd;
	klee_make_symbolic(&t84710467_540e_4c78_b9f4_a4a8cde883cd, sizeof(t84710467_540e_4c78_b9f4_a4a8cde883cd), "t84710467_540e_4c78_b9f4_a4a8cde883cd");
	meta.stats_metadata.senderIP = t84710467_540e_4c78_b9f4_a4a8cde883cd;

	
	uint64_t tc2657781_89c5_4494_8e21_499aa8caec4b;
	klee_make_symbolic(&tc2657781_89c5_4494_8e21_499aa8caec4b, sizeof(tc2657781_89c5_4494_8e21_499aa8caec4b), "tc2657781_89c5_4494_8e21_499aa8caec4b");
	meta.stats_metadata.seqNo = tc2657781_89c5_4494_8e21_499aa8caec4b;

	
	uint64_t t397c4235_0d25_461d_a146_a5548f85870c;
	klee_make_symbolic(&t397c4235_0d25_461d_a146_a5548f85870c, sizeof(t397c4235_0d25_461d_a146_a5548f85870c), "t397c4235_0d25_461d_a146_a5548f85870c");
	meta.stats_metadata.ackNo = t397c4235_0d25_461d_a146_a5548f85870c;

	
	uint64_t t33d4b0dc_4a79_4d9a_8866_01d06bbeaa6d;
	klee_make_symbolic(&t33d4b0dc_4a79_4d9a_8866_01d06bbeaa6d, sizeof(t33d4b0dc_4a79_4d9a_8866_01d06bbeaa6d), "t33d4b0dc_4a79_4d9a_8866_01d06bbeaa6d");
	meta.stats_metadata.sample_rtt_seq = t33d4b0dc_4a79_4d9a_8866_01d06bbeaa6d;

	
	uint64_t t0042b193_6254_498c_9290_8b199fb35363;
	klee_make_symbolic(&t0042b193_6254_498c_9290_8b199fb35363, sizeof(t0042b193_6254_498c_9290_8b199fb35363), "t0042b193_6254_498c_9290_8b199fb35363");
	meta.stats_metadata.rtt_samples = t0042b193_6254_498c_9290_8b199fb35363;

	
	uint64_t tdd4becaa_adba_48c2_b312_88bc177dfe51;
	klee_make_symbolic(&tdd4becaa_adba_48c2_b312_88bc177dfe51, sizeof(tdd4becaa_adba_48c2_b312_88bc177dfe51), "tdd4becaa_adba_48c2_b312_88bc177dfe51");
	meta.stats_metadata.mincwnd = tdd4becaa_adba_48c2_b312_88bc177dfe51;

	
	uint64_t t543c8d31_64cb_4a09_aedb_760122b697d0;
	klee_make_symbolic(&t543c8d31_64cb_4a09_aedb_760122b697d0, sizeof(t543c8d31_64cb_4a09_aedb_760122b697d0), "t543c8d31_64cb_4a09_aedb_760122b697d0");
	meta.stats_metadata.dupack = t543c8d31_64cb_4a09_aedb_760122b697d0;


}


// Action
void use_sample_rtt_first_0_458416() {
	action_run = 458416;
		
	uint64_t t8fd99da7_2390_4faa_b72e_1c8d2fe8ec76;
	klee_make_symbolic(&t8fd99da7_2390_4faa_b72e_1c8d2fe8ec76, sizeof(t8fd99da7_2390_4faa_b72e_1c8d2fe8ec76), "t8fd99da7_2390_4faa_b72e_1c8d2fe8ec76");
	meta.stats_metadata.dummy = t8fd99da7_2390_4faa_b72e_1c8d2fe8ec76;

	meta.stats_metadata.dummy2 = (uint32_t) meta.intrinsic_metadata.ingress_global_timestamp;
	meta.stats_metadata.dummy2 = meta.intrinsic_metadata.ingress_global_timestamp - meta.stats_metadata.dummy;

}


// Action
void update_flow_dupack_0_453843() {
	action_run = 453843;
		
	uint64_t td57b7426_1259_40f2_b38e_53c8db694035;
	klee_make_symbolic(&td57b7426_1259_40f2_b38e_53c8db694035, sizeof(td57b7426_1259_40f2_b38e_53c8db694035), "td57b7426_1259_40f2_b38e_53c8db694035");
	meta.stats_metadata.dummy = td57b7426_1259_40f2_b38e_53c8db694035;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy + 1;

}


// Action
void update_flow_rcvd_0_453896() {
	action_run = 453896;
		
	uint64_t t027c3367_c295_4744_92d9_7f71fe8da4cf;
	klee_make_symbolic(&t027c3367_c295_4744_92d9_7f71fe8da4cf, sizeof(t027c3367_c295_4744_92d9_7f71fe8da4cf), "t027c3367_c295_4744_92d9_7f71fe8da4cf");
	meta.stats_metadata.dummy = t027c3367_c295_4744_92d9_7f71fe8da4cf;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy + 1;

}


// Action
void update_flow_retx_3dupack_0_454011() {
	action_run = 454011;
		meta_stats_metadata_dupack_le_3_454027 = (meta.stats_metadata.dupack  <  3);
	traverse_454027 = 1;
	
	uint64_t t6cdeb88d_183a_496b_bd1c_7545b4500045;
	klee_make_symbolic(&t6cdeb88d_183a_496b_bd1c_7545b4500045, sizeof(t6cdeb88d_183a_496b_bd1c_7545b4500045), "t6cdeb88d_183a_496b_bd1c_7545b4500045");
	meta.stats_metadata.dummy = t6cdeb88d_183a_496b_bd1c_7545b4500045;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy + 1;
	
	uint64_t t1eef1073_2268_4adb_9b9f_f0c4a478783b;
	klee_make_symbolic(&t1eef1073_2268_4adb_9b9f_f0c4a478783b, sizeof(t1eef1073_2268_4adb_9b9f_f0c4a478783b), "t1eef1073_2268_4adb_9b9f_f0c4a478783b");
	meta.stats_metadata.dummy = t1eef1073_2268_4adb_9b9f_f0c4a478783b;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy >> 1;

}


// Action
void update_flow_retx_timeout_0_454141() {
	action_run = 454141;
		
	uint64_t t7814ce3c_d0d1_42be_ac04_b1119828690e;
	klee_make_symbolic(&t7814ce3c_d0d1_42be_ac04_b1119828690e, sizeof(t7814ce3c_d0d1_42be_ac04_b1119828690e), "t7814ce3c_d0d1_42be_ac04_b1119828690e");
	meta.stats_metadata.dummy = t7814ce3c_d0d1_42be_ac04_b1119828690e;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy + 1;

}


// Action
void update_flow_sent_0_454233() {
	action_run = 454233;
		
	uint64_t te1b91cfe_5d0f_4530_a884_0be722efb1a8;
	klee_make_symbolic(&te1b91cfe_5d0f_4530_a884_0be722efb1a8, sizeof(te1b91cfe_5d0f_4530_a884_0be722efb1a8), "te1b91cfe_5d0f_4530_a884_0be722efb1a8");
	meta.stats_metadata.dummy = te1b91cfe_5d0f_4530_a884_0be722efb1a8;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy + 1;
	meta.stats_metadata.dummy = (uint32_t) meta.intrinsic_metadata.ingress_global_timestamp;
	
	uint64_t t3a4972fa_fbbd_4235_b9aa_fd47bb2f6e52;
	klee_make_symbolic(&t3a4972fa_fbbd_4235_b9aa_fd47bb2f6e52, sizeof(t3a4972fa_fbbd_4235_b9aa_fd47bb2f6e52), "t3a4972fa_fbbd_4235_b9aa_fd47bb2f6e52");
	meta.stats_metadata.dummy2 = t3a4972fa_fbbd_4235_b9aa_fd47bb2f6e52;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy - meta.stats_metadata.dummy2;
	
	uint64_t t5ed0309f_6b03_4d51_8a63_e7eb5084dca2;
	klee_make_symbolic(&t5ed0309f_6b03_4d51_8a63_e7eb5084dca2, sizeof(t5ed0309f_6b03_4d51_8a63_e7eb5084dca2), "t5ed0309f_6b03_4d51_8a63_e7eb5084dca2");
	meta.stats_metadata.dummy = t5ed0309f_6b03_4d51_8a63_e7eb5084dca2;

	
	uint64_t tc41b4e19_7e83_4d1c_b753_4eb7539bdea3;
	klee_make_symbolic(&tc41b4e19_7e83_4d1c_b753_4eb7539bdea3, sizeof(tc41b4e19_7e83_4d1c_b753_4eb7539bdea3), "tc41b4e19_7e83_4d1c_b753_4eb7539bdea3");
	meta.stats_metadata.dummy2 = tc41b4e19_7e83_4d1c_b753_4eb7539bdea3;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy - meta.stats_metadata.dummy2;

}


// Action
void set_dmac_0_454420() {
	action_run = 454420;
	uint64_t dmac;
	klee_make_symbolic(&dmac, sizeof(dmac), "dmac");
	hdr.ethernet.dstAddr = dmac;

}


// Action
void _drop_1_454438() {
	action_run = 454438;
		mark_to_drop();

}


// Action
void _drop_4_454454() {
	action_run = 454454;
		mark_to_drop();

}


// Action
void increase_mincwnd_0_454461() {
	action_run = 454461;
	
}


// Action
void record_IP_0_454487() {
	action_run = 454487;
		
	uint64_t tc9585c7b_790e_494a_9f60_75e1b3890aab;
	klee_make_symbolic(&tc9585c7b_790e_494a_9f60_75e1b3890aab, sizeof(tc9585c7b_790e_494a_9f60_75e1b3890aab), "tc9585c7b_790e_494a_9f60_75e1b3890aab");
	meta.stats_metadata.senderIP = tc9585c7b_790e_494a_9f60_75e1b3890aab;


}


// Action
void set_nhop_0_454574() {
	action_run = 454574;
	uint32_t nhop_ipv4;
	klee_make_symbolic(&nhop_ipv4, sizeof(nhop_ipv4), "nhop_ipv4");
uint32_t port;
	klee_make_symbolic(&port, sizeof(port), "port");
	meta.routing_metadata.nhop_ipv4 = nhop_ipv4;
	standard_metadata.egress_spec = port;
	hdr.ipv4.ttl = hdr.ipv4.ttl + 255;
}


// Action
void lookup_flow_map_0_454610() {
	action_run = 454610;
		
	uint64_t t12faf59b_7eed_401f_8b88_85a14fdc44c3;
	klee_make_symbolic(&t12faf59b_7eed_401f_8b88_85a14fdc44c3, sizeof(t12faf59b_7eed_401f_8b88_85a14fdc44c3), "t12faf59b_7eed_401f_8b88_85a14fdc44c3");
	meta.stats_metadata.flow_map_index = t12faf59b_7eed_401f_8b88_85a14fdc44c3;


}


// Action
void lookup_flow_map_reverse_0_454672() {
	action_run = 454672;
		
	uint64_t t4e5dad2d_c703_4505_91bd_095317cef223;
	klee_make_symbolic(&t4e5dad2d_c703_4505_91bd_095317cef223, sizeof(t4e5dad2d_c703_4505_91bd_095317cef223), "t4e5dad2d_c703_4505_91bd_095317cef223");
	meta.stats_metadata.flow_map_index = t4e5dad2d_c703_4505_91bd_095317cef223;


}


// Action
void use_sample_rtt_0_459912() {
	action_run = 459912;
		
	uint64_t t1bc1f8cd_431f_40a1_a56a_30b3fb7aee68;
	klee_make_symbolic(&t1bc1f8cd_431f_40a1_a56a_30b3fb7aee68, sizeof(t1bc1f8cd_431f_40a1_a56a_30b3fb7aee68), "t1bc1f8cd_431f_40a1_a56a_30b3fb7aee68");
	meta.stats_metadata.dummy = t1bc1f8cd_431f_40a1_a56a_30b3fb7aee68;

	meta.stats_metadata.dummy2 = (uint32_t) meta.intrinsic_metadata.ingress_global_timestamp;
	meta.stats_metadata.dummy2 = meta.intrinsic_metadata.ingress_global_timestamp - meta.stats_metadata.dummy;
	
	uint64_t t5cf0c290_3447_4bec_982f_ad887f31367e;
	klee_make_symbolic(&t5cf0c290_3447_4bec_982f_ad887f31367e, sizeof(t5cf0c290_3447_4bec_982f_ad887f31367e), "t5cf0c290_3447_4bec_982f_ad887f31367e");
	meta.stats_metadata.dummy = t5cf0c290_3447_4bec_982f_ad887f31367e;

	meta.stats_metadata.dummy = 7 * meta.stats_metadata.dummy + meta.stats_metadata.dummy2;
	meta.stats_metadata.dummy = meta.stats_metadata.dummy >> 3;
	
	uint64_t t41623da2_e52b_4cf5_9c2d_ef3958befb03;
	klee_make_symbolic(&t41623da2_e52b_4cf5_9c2d_ef3958befb03, sizeof(t41623da2_e52b_4cf5_9c2d_ef3958befb03), "t41623da2_e52b_4cf5_9c2d_ef3958befb03");
	meta.stats_metadata.dummy = t41623da2_e52b_4cf5_9c2d_ef3958befb03;

	meta.stats_metadata.dummy = meta.stats_metadata.dummy + 1;

}


// Action
void sample_new_rtt_0_454900() {
	action_run = 454900;
	
}


//Table
void debug_454943() {
        klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
        switch(symbol) {
		case 0: save_source_IP_0_453564(); break;
		default: NoAction_1_453262(); break;
	}
}


//Table
void direction_454977() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
        //switch(klee_int("symbol")){
		case 0: get_sender_IP_0_453622(); break;
		default: NoAction_19_453263(); break;
	}
	// default_action NoAction_19();

}


//Table
void first_rtt_sample_455011() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: use_sample_rtt_first_0_458416(); break;
		default: NoAction_20_453264(); break;
	}
	// default_action NoAction_20();

}


//Table
void flow_dupack_455045() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
        //switch(klee_int("symbol")){
		case 0: update_flow_dupack_0_453843(); break;
		default: NoAction_21_453265(); break;
	}
	// default_action NoAction_21();

}


//Table
void flow_rcvd_455079() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: update_flow_rcvd_0_453896(); break;
		default: NoAction_22_453266(); break;
	}
	// default_action NoAction_22();

}


//Table
void flow_retx_3dupack_455113() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: update_flow_retx_3dupack_0_454011(); break;
		default: NoAction_23_453267(); break;
	}
	// default_action NoAction_23();

}


//Table
void flow_retx_timeout_455147() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: update_flow_retx_timeout_0_454141(); break;
		default: NoAction_24_453268(); break;
	}
	// default_action NoAction_24();

}


//Table
void flow_sent_455181() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: update_flow_sent_0_454233(); break;
		default: NoAction_25_453269(); break;
	}
	// default_action NoAction_25();

}


//Table
void forward_455215() {
//	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: set_dmac_0_454420(); break;
		case 1: _drop_1_454438(); break;
		default: NoAction_26_453270(); break;
	}
	// keys: meta.routing_metadata.nhop_ipv4:exact
	// size 512
	// default_action NoAction_26();

}


//Table
void increase_cwnd_455274() {
//	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: increase_mincwnd_0_454461(); break;
		default: NoAction_27_453271(); break;
	}
	// default_action NoAction_27();

}


//Table
void init_455308() {
	//int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: record_IP_0_454487(); break;
		default: NoAction_28_453272(); break;
	}
	// default_action NoAction_28();

}


//Table
void ipv4_lpm_455342() {
//	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: set_nhop_0_454574(); break;
		case 1: _drop_4_454454(); break;
		default: NoAction_29_453273(); break;
	}
	// keys: hdr.ipv4.dstAddr:lpm
	// size 1024
	// default_action NoAction_29();

}


//Table
void lookup_455401() {
//	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: lookup_flow_map_0_454610(); break;
		default: NoAction_30_453274(); break;
	}
	// default_action NoAction_30();

}


//Table
void lookup_reverse_455435() {
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: lookup_flow_map_reverse_0_454672(); break;
		default: NoAction_31_453275(); break;
	}
	// default_action NoAction_31();

}


//Table
void sample_rtt_rcvd_455469() {
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: use_sample_rtt_0_459912(); break;
		default: NoAction_32_453276(); break;
	}
	// default_action NoAction_32();

}


//Table
void sample_rtt_sent_455503() {
//	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
//switch(klee_int("symbol")){
		case 0: sample_new_rtt_0_454900(); break;
		default: NoAction_33_453277(); break;
	}
	// default_action NoAction_33();

}

typedef struct {
	uint8_t field_4 : 4;
	uint8_t field_5 : 4;
	uint8_t field_6 : 8;
	uint32_t field_7 : 16;
	uint32_t field_8 : 16;
	uint8_t field_9 : 3;
	uint32_t field_10 : 13;
	uint8_t field_11 : 8;
	uint8_t field_12 : 8;
	uint32_t field_13 : 32;
	uint32_t field_14 : 32;
} tuple_1;

//Control

void verifyChecksum() {
	verify_checksum();
}


//Control

void computeChecksum() {
	update_checksum();
}


int main() {
	ParserImpl();
	ingress();
	egress();
	end_assertions();
	return 0;
}

void end_assertions(){


	if(!(!(hdr_tcp_ack_453638) || (traverse_453638))) klee_print_once(0 , "!(hdr_tcp_ack_453638) || (traverse_453638)");
	if(!(!(meta_stats_metadata_dupack_le_3_454027) || (!traverse_454027))) klee_print_once(1, "!(meta_stats_metadata_dupack_le_3_454027) || (!traverse_454027)");
	if(!(!(hdr_ipv4_ttl_eq_0_455545) || (!assert_forward))) klee_print_once(2, "!(hdr_ipv4_ttl_eq_0_455545) || (!assert_forward)");
	///if(!(constant_hdr_tcp_dstPort_455552 == hdr.tcp.dstPort)) assert_error("constant_hdr_tcp_dstPort_455552 == hdr.tcp.dstPort");
	///if(!(constant_hdr_tcp_seqNo_455559 == hdr.tcp.seqNo)) assert_error("constant_hdr_tcp_seqNo_455559 == hdr.tcp.seqNo");
	///if(!(constant_hdr_tcp_ackNo_455566 == hdr.tcp.ackNo)) assert_error("constant_hdr_tcp_ackNo_455566 == hdr.tcp.ackNo");
	///if(!(constant_hdr_tcp_dataOffset_455573 == hdr.tcp.dataOffset)) assert_error("constant_hdr_tcp_dataOffset_455573 == hdr.tcp.dataOffset");
	///if(!(constant_hdr_tcp_res_455580 == hdr.tcp.res)) assert_error("constant_hdr_tcp_res_455580 == hdr.tcp.res");
	///if(!(constant_hdr_tcp_ecn_455587 == hdr.tcp.ecn)) assert_error("constant_hdr_tcp_ecn_455587 == hdr.tcp.ecn");
	///if(!(constant_hdr_tcp_urg_455594 == hdr.tcp.urg)) assert_error("constant_hdr_tcp_urg_455594 == hdr.tcp.urg");
	///if(!(constant_hdr_tcp_ack_455601 == hdr.tcp.ack)) assert_error("constant_hdr_tcp_ack_455601 == hdr.tcp.ack");
	///if(!(constant_hdr_tcp_push_455608 == hdr.tcp.push)) assert_error("constant_hdr_tcp_push_455608 == hdr.tcp.push");
	///if(!(constant_hdr_tcp_rst_455615 == hdr.tcp.rst)) assert_error("constant_hdr_tcp_rst_455615 == hdr.tcp.rst");
	///if(!(constant_hdr_tcp_syn_455622 == hdr.tcp.syn)) assert_error("constant_hdr_tcp_syn_455622 == hdr.tcp.syn");
	///if(!(constant_hdr_tcp_fin_455629 == hdr.tcp.fin)) assert_error("constant_hdr_tcp_fin_455629 == hdr.tcp.fin");
	///if(!(constant_hdr_tcp_window_455636 == hdr.tcp.window)) assert_error("constant_hdr_tcp_window_455636 == hdr.tcp.window");
	///if(!(constant_hdr_tcp_checksum_455643 == hdr.tcp.checksum)) assert_error("constant_hdr_tcp_checksum_455643 == hdr.tcp.checksum");
	///if(!(constant_hdr_tcp_urgentPtr_455650 == hdr.tcp.urgentPtr)) assert_error("constant_hdr_tcp_urgentPtr_455650 == hdr.tcp.urgentPtr");

}



