// mc_nat.p4
// performs "multicast NAT replication", i.e. for every one
// packet that comes in, several packets come out with
// different DST IPs and from different egress ports
//
// This code is dependent on the BMv2-SimpleSwitch target's
// Packet Replication Engine (PRE)
//
// Authors: Thomas Edwards (thomas.edwards@fox.com)
//          Vladimir Gurevich (Barefoot Networks)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This is BMv2-SimpleSwitch-specific Ingress Metadata
header_type intrinsic_metadata_t {
    fields {
        mcast_grp : 16;                        /* multicast group */
        lf_field_list : 32;                    /* Learn filter field list */
        egress_rid : 16;                       /* replication index */
        ingress_global_timestamp : 32;
    }
}
metadata intrinsic_metadata_t intrinsic_metadata;

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
        length_ : 16;
        checksum : 16;
    }
}

// We must update IP checksum, otherwise, the packets will not be quite valid...
field_list ipv4_checksum_list {
    ipv4.version;
    ipv4.ihl;
    ipv4.diffserv;
    ipv4.totalLen;
    ipv4.identification;
    ipv4.flags;
    ipv4.fragOffset;
    ipv4.ttl;
    ipv4.protocol;
    ipv4.srcAddr;
    ipv4.dstAddr;
}

field_list_calculation ipv4_checksum {
    input {
        ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field ipv4.hdrChecksum  {
    verify ipv4_checksum;
    update ipv4_checksum;
}

// Similarly, we need to update UDP Checksum. We can't check it, though...
field_list udp_checksum_list {
    ipv4.srcAddr;
    ipv4.dstAddr;
    8'0;
    ipv4.protocol;
    udp.length_;
    udp.srcPort;
    udp.dstPort;
    udp.length_ ;
    payload;
}

field_list_calculation udp_checksum {
    input {
        udp_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field udp.checksum {
    update udp_checksum;
}

////////////////////////////////////////////////////////////////////////////
//////////   PARSER (Ethernet/IPv4/UDP)
////////////////////////////////////////////////////////////////////////////
header ethernet_t ethernet;
header ipv4_t ipv4;
header udp_t  udp;

parser start {
    return parse_ethernet;
}

#define ETHERTYPE_IPV4 0x0800

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;
        default: ingress;
   }
}

#define PROTOCOL_UDP 0x11

parser parse_ipv4 {
    extract(ipv4);
    return select(ipv4.protocol) {
        PROTOCOL_UDP: parse_udp;
        default: ingress;
    }
}

parser parse_udp {
    extract(udp);
    return ingress;
}

/////////////////////////////////////////////////////////////////////////////
/////////// Actions
/////////////////////////////////////////////////////////////////////////////
action set_output_mcg(mcast_group) {
    modify_field(intrinsic_metadata.mcast_grp, mcast_group);
}

action do_nat(dst_ip) {
      modify_field(ipv4.dstAddr,dst_ip);
      add_to_field(ipv4.ttl, -1);        // Just for fun :)
}

action _drop() {
    drop();
}

/////////////////////////////////////////////////////////////////////////////
/////////// Tables
/////////////////////////////////////////////////////////////////////////////

// Table to set the multicast group based on the IPv4 dstAddr
//
table set_mcg {
    reads {
        ipv4.dstAddr: exact;
    }
    actions {
        set_output_mcg; 
	    _drop;
    }
    size : 16384;
}

// Table to do the network address translation on the IPv4 dstAddr
// based on the original IPv4 dstAddr and the egress Replication ID
// (rid)
// 
table nat_table {
    reads {
        intrinsic_metadata.egress_rid : exact;
    	ipv4.dstAddr: exact; 
    }
    actions {
        do_nat; 
        _drop;
    }
    size : 16384;
}

/////////////////////////////////////////////////////////////////////////////
/////////// Control 
/////////////////////////////////////////////////////////////////////////////

control ingress {
    apply(set_mcg);
}

control egress {
    apply(nat_table);
}
