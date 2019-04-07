/* Copyright 2013-present Barefoot Networks, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "hh_tracker.p4"

header_type ethernet_t {
    fields {
        bit<48> dstAddr;
        bit<48> srcAddr;
        bit<16> etherType;
    }
}

header_type ipv4_t {
    fields {
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
}

parser start {
    return parse_ethernet;
}

#define ETHERTYPE_IPV4 0x0800

header ethernet_t ethernet;

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;
        default: ingress;
    }
}

header ipv4_t ipv4;

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

parser parse_ipv4 {
    extract(ipv4);
    return ingress;
}


action _drop() {
    drop();
}

header_type tracking_metadata_t {
    fields {
        bit<32> mKeyInTable;
        bit<32> mCountInTable;
        bit<10> mIndex;
        bit<1> mValid;
        bit<32> mKeyCarried;
        bit<32> mCountCarried;
        bit<32> mSwapSpace;
    }
}

metadata tracking_metadata_t track_meta;

header_type routing_metadata_t {
    fields {
        bit<32> nhop_ipv4;
    }
}

metadata routing_metadata_t routing_metadata;

register drops_register {
    width: 32;
    static: drop_expired;
    instance_count: 16;
}

register drops_register_enabled {
    width: 1;
    static: drop_expired;
    instance_count: 16;
}

action do_drop_expired() {
    drops_register[0] = drops_register[0] + ((drops_register_enabled[0] == 1) ?
    (bit<32>)1 : 0);
    //packet_counter[0] = packet_counter[0] + (bit<32>)1;
    drop();
}

table drop_expired {
    actions { do_drop_expired; }
    size: 0;
}

field_list hash_list {
    ipv4.srcAddr;
    //ipv4.dstAddr;
}

field_list_calculation stage1_hash {
    input {
        hash_list;
    }
    algorithm : crc16;
    output_width : 10;
}

register flow_tracker_stage1 {
    width: 32;
    static: track_stage1;
    instance_count: 1024;
}

register packet_counter_stage1 {
    width: 32;
    static: track_stage1;
    instance_count: 1024;
}

register valid_bit_stage1 {
    width: 1;
    static: track_stage1;
    instance_count: 1024;
}

action do_stage1(){
    // first table stage
    track_meta.mKeyCarried = ipv4.srcAddr;
    track_meta.mCountCarried = 0;

    // hash using my custom function 
    modify_field_with_hash_based_offset(track_meta.mIndex, 0, stage1_hash, 1024);

    // read the key and value at that location
    track_meta.mKeyInTable = flow_tracker_stage1[track_meta.mIndex];
    track_meta.mCountInTable = packet_counter_stage1[track_meta.mIndex];
    track_meta.mValid = valid_bit_stage1[track_meta.mIndex];

    // check if location is empty or has a differentkey in there
    track_meta.mKeyInTable = (track_meta.mValid == 0)? track_meta.mKeyCarried : track_meta.mKeyInTable;
    track_meta.mSwapSpace = track_meta.mKeyInTable - track_meta.mKeyCarried;

    // update hash table
    flow_tracker_stage1[track_meta.mIndex] = track_meta.mKeyCarried;
    packet_counter_stage1[track_meta.mIndex] = ((track_meta.mSwapSpace == 0)?
    track_meta.mCountInTable + 1 : 1);
    valid_bit_stage1[track_meta.mIndex] = 1;

    // update metadata carried to the next table stage
    track_meta.mKeyCarried = ((track_meta.mSwapSpace == 0) ? 0:
    track_meta.mKeyInTable);
    track_meta.mCountCarried = ((track_meta.mSwapSpace == 0) ? 0:
    track_meta.mCountInTable);  
}

table track_stage1 {
    actions { do_stage1; }
    size: 0;
}       

action set_nhop(in bit<32> nhop_ipv4, in bit<9> port) {
    routing_metadata.nhop_ipv4 = nhop_ipv4;
    standard_metadata.egress_spec = port;
    ipv4.ttl = ipv4.ttl - 1;
}

table ipv4_lpm {
    reads {
        ipv4.dstAddr : lpm;
    }
    actions {
        set_nhop;
        _drop;
    }
    size: 1024;
}

action set_dmac(in bit<48> dmac) {
    ethernet.dstAddr = dmac;
    // modify_field still valid
    // modify_field(ethernet.dstAddr, dmac);
}

table forward {
    reads {
        routing_metadata.nhop_ipv4 : exact;
    }
    actions {
        set_dmac;
        _drop;
    }
    size: 512;
}

action rewrite_mac(in bit<48> smac) {
    ethernet.srcAddr = smac;
}

table send_frame {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        rewrite_mac;
        _drop;
    }
    size: 256;
}

control ingress {
    if(valid(ipv4)) {
        apply(track_stage1);
        if(ipv4.ttl > 1) {
            apply(ipv4_lpm);
            apply(forward);
        } else {
            apply(drop_expired);
        }
    }
}

control egress {
    apply(send_frame);
}
