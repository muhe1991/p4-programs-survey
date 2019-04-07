// Scheduled media switching based on RTP timestamp
// Author: Thomas Edwards (thomas.edwards@fox.com)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

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
        dstAddr : 32;
    }
}

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        hdr_length : 16;
        checksum : 16;
    }
}
    
header_type rtp_t {
    fields {
        version : 2;
        padding : 1;
        extension : 1;
        CSRC_count : 4;
        marker : 1;
        payload_type : 7;
        sequence_number : 16;
        timestamp : 32;
        SSRC : 32;
    }
} 

parser start {
    return parse_ethernet;
}

header ethernet_t ethernet;

#define ETHERTYPE_IPV4 0x0800

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;
        default: ingress;
   }
}

header ipv4_t ipv4;

#define PROTOCOL_UDP 0x11

parser parse_ipv4 {
    extract(ipv4);
    return select(ipv4.protocol) {
        PROTOCOL_UDP : parse_udp;
	default: ingress;
  }
}

header udp_t udp;

parser parse_udp {
    extract(udp);
    return parse_rtp;
}

header rtp_t rtp;

parser parse_rtp {
    extract(rtp);
    return ingress;
}

counter my_direct_counter {
    type: bytes;
    direct: schedule_table;
}

action take_video(dst_ip) {
      modify_field(standard_metadata.egress_spec,1);
      modify_field(ipv4.dstAddr,dst_ip);
}

action _drop() {
    drop();
}

table schedule_table {
    reads {
	ipv4.dstAddr: exact;
        rtp.timestamp: range;
    }
    actions {
        take_video; 
        _drop;
    }
    size : 16384;
}

control ingress {
    apply(schedule_table);
}

control egress {
}
