#define BITSLICE(x, a, b) ((x) >> (b)) & ((1 << ((a)-(b)+1)) - 1)
#include<stdio.h>
#include<stdint.h>
#include<stdlib.h>

int assert_forward = 1;
int action_run;

int traverse_color_check = 0;
int standard_metadata_ingress_port_eq_1_137028;
int hdr_ipv4_dstAddr_eq_167772162_137028;

void color_check_137023();
void set_source_color_0_136769(uint8_t color);
void NoAction_6_136752();
void set_remote_dest_0_136868();
void drop_0_136753();
void core_pass_through_0_136945();
void NoAction_1_136751();
void accept();
void NoAction_7_137142();
void set_local_dest_0_136835(uint32_t egr_port, uint8_t color);
void start();
void get_source_color_136787();
void forward_136962();
void place_holder_table_137143();
void parse_ipv4_option();
void reject();
void parse_ipv4();
void NoAction_0_136741();
void parse_stag();
void end_assertions();

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

typedef uint64_t macAddr_t;

typedef uint32_t ip4Addr_t;

typedef struct {
	uint8_t isValid : 1;
	macAddr_t dstAddr: 48;
	macAddr_t srcAddr: 48;
	uint32_t etherType : 16;
	uint8_t $valid$ : 1;
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
	ip4Addr_t srcAddr: 32;
	ip4Addr_t dstAddr: 32;
	uint8_t $valid$ : 1;
} ipv4_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t copyFlag : 1;
	uint8_t optClass : 2;
	uint8_t option : 5;
	uint8_t optionLength : 8;
	uint8_t $valid$ : 1;
} ipv4_option_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t source_color : 8;
	uint8_t $valid$ : 1;
} stag_t;

typedef struct {
	uint8_t isValid : 1;
	uint8_t src_port_color : 8;
	uint8_t dst_port_color : 8;
	uint8_t toLocal : 1;
	uint8_t $valid$ : 1;
} local_md_t;

typedef struct {
	local_md_t local_md;
} metadata;

typedef struct {
	ethernet_t ethernet;
	ipv4_t ipv4;
	ipv4_option_t ipv4_option;
	stag_t stag;
} headers;

headers hdr;
metadata meta;
standard_metadata_t standard_metadata;

void end_assertions(){
	if(traverse_color_check && standard_metadata_ingress_port_eq_1_137028 && hdr_ipv4_dstAddr_eq_167772162_137028 && assert_forward){
		printf("Assert error: if expression standard_metadata.ingress_port == 1 && hdr.ipv4.dstAddr == 167772162, !forward evaluated to false\n");
	}

}

void start() {
	//Extract hdr.ethernet
	hdr.ethernet.isValid = 1;
	klee_assume(hdr.ethernet.etherType != 2048);
//	if((hdr.ethernet.etherType == 2048)){
//		parse_ipv4();
//	} else {
		accept();
//	}
}


void parse_ipv4() {
	//Extract hdr.ipv4
	hdr.ipv4.isValid = 1;
	if(hdr.ipv4.ihl >= 5) { exit(1); }
	if((hdr.ipv4.ihl == 5)){
		accept();
	} else {
		parse_ipv4_option();
	}
}


void parse_ipv4_option() {
	//Extract hdr.ipv4_option
	hdr.ipv4_option.isValid = 1;
	if((hdr.ipv4_option.option == 31)){
		parse_stag();
	} else {
		accept();
	}
}


void parse_stag() {
	//Extract hdr.stag
	hdr.stag.isValid = 1;
	meta.local_md.src_port_color = hdr.stag.source_color;
	accept();
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

void ingress() {
	if((hdr.stag.isValid != 1)) {
		get_source_color_136787();
	}
	forward_136962();
	if(action_run == 136835) {
		color_check_137023();

	}
}

// Action
void NoAction_0_136741() {
	action_run = 136741;

}


// Action
void NoAction_1_136751() {
	action_run = 136751;

}


// Action
void NoAction_6_136752() {
	action_run = 136752;

}


// Action
void drop_0_136753() {
	action_run = 136753;
	mark_to_drop();

}


// Action
void set_source_color_0_136769(uint8_t color) {
	action_run = 136769;
	meta.local_md.src_port_color = color;

}


// Action
void set_local_dest_0_136835(uint32_t egr_port, uint8_t color) {
	action_run = 136835;
	standard_metadata.egress_spec = egr_port;
	meta.local_md.dst_port_color = color;
	hdr.stag.isValid = 0;

}


// Action
void set_remote_dest_0_136868() {
	action_run = 136868;
	uint32_t egr_port;
	klee_make_symbolic(&egr_port, sizeof(egr_port), "egr_port");
	standard_metadata.egress_spec = egr_port;
	hdr.ipv4_option.isValid = 1;
	hdr.ipv4_option.copyFlag = 1;
	hdr.ipv4_option.optClass = 2;
	hdr.ipv4_option.option = 31;
	hdr.ipv4_option.optionLength = 4;
	hdr.ipv4.ihl = hdr.ipv4.ihl + 1;
	hdr.stag.isValid = 1;
	hdr.stag.source_color = meta.local_md.src_port_color;

}


// Action
void core_pass_through_0_136945() {
	action_run = 136945;
	uint32_t egr_port;
	klee_make_symbolic(&egr_port, sizeof(egr_port), "egr_port");
	standard_metadata.egress_spec = egr_port;

}


//Table
void get_source_color_136787() {
	klee_assume(standard_metadata.ingress_port != 1);
}


//Table
void forward_136962() {
	if(hdr.ipv4.dstAddr == 167772162){
		set_local_dest_0_136835(2, 1);
	}
}

// Table
void color_check_137023() {

	traverse_color_check = 1;
	standard_metadata_ingress_port_eq_1_137028 = (standard_metadata.ingress_port == 1);
	hdr_ipv4_dstAddr_eq_167772162_137028 = (hdr.ipv4.dstAddr == 167772162);

	if(meta.local_md.dst_port_color == 1 && meta.local_md.src_port_color == 0){
		drop_0_136753();
	}
}



//Control

void egress() {
	place_holder_table_137143();
}

// Action
void NoAction_7_137142() {
	action_run = 137142;

}


//Table
void place_holder_table_137143() {
	int symbol;
	klee_make_symbolic(&symbol, sizeof(symbol), "symbol");
	switch(symbol) {
		default: NoAction_7_137142(); break;
	}
	// size 2
	// default_action NoAction_7();

}



//Control

void computeChecksum() {

}


//Control

void verifyChecksum() {

}


//Control

void DeparserImpl() {
	//Emit hdr.ethernet

	//Emit hdr.ipv4

	//Emit hdr.ipv4_option

	//Emit hdr.stag

}

int main() {
	ParserImpl();
	ingress();
	egress();
	DeparserImpl();
	end_assertions();
	return 0;
}



