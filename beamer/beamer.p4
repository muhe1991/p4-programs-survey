/* Copyright 2013-present Barefoot Networks, Inc.,
 * 2018 University Politehnica of Bucharest
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
        dstAddr: 32;
    }
}
header_type tcp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        sequence : 32;
        ack : 32;
        len : 4;
        reserved : 6;
        flags : 6;
        window : 16;
        check : 16;
        urgent : 16;
    }
}

header_type mplb_t {
    fields { 
        tip : 8;
        lengt : 8;
        pointer : 8;
        clientip : 32;
        virtualip : 32;
        blank : 8;
    }
}

header_type mplb_ipopt_t {
    fields {
        copied : 1;
        class : 2;
        number : 5;
        len : 8;
        padding : 16;
        pdip : 32;
        ts : 32;
        gen : 32;
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
header ipv4_t inner_ipv4;
header tcp_t tcp;
header mplb_t mplb;
header mplb_ipopt_t mplb_ipopt;

field_list recirc_FL {
        standard_metadata;
        hash_metadata;
}
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
        mplb_ipopt.copied;
        mplb_ipopt.class;
        mplb_ipopt.number;
        mplb_ipopt.len;
        mplb_ipopt.ts;
        mplb_ipopt.pdip;
}
field_list mplb_hash_list {
        //ipv4.dstAddr;
        ipv4.srcAddr;
        //ipv4.protocol;
        //tcp.dstPort;
        tcp.srcPort;
}

field_list_calculation ipv4_checksum {
    input {
        ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

field_list inner_ipv4_checksum_list {
    inner_ipv4.version;
    inner_ipv4.ihl;
    inner_ipv4.diffserv;
    inner_ipv4.totalLen;
    inner_ipv4.identification;
    inner_ipv4.flags;
    inner_ipv4.fragOffset;
    inner_ipv4.ttl;
    inner_ipv4.protocol;
    inner_ipv4.srcAddr;
    inner_ipv4.dstAddr;
}

field_list_calculation inner_ipv4_checksum {
    input {
        inner_ipv4_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field inner_ipv4.hdrChecksum {
    update inner_ipv4_checksum if(valid(ipv4));
}


field_list_calculation mplb_hash_calculation {
    input {
        mplb_hash_list;
    }
    algorithm : crc32;
    output_width : 32;
}

calculated_field hash_metadata.mplb_hash {
    update mplb_hash_calculation;
}

calculated_field ipv4.hdrChecksum  {
    update ipv4_checksum;
}

parser parse_mplb {
    extract(mplb);
    return parse_tcp;
}
parser parse_mplb_ipopt {
    extract(mplb_ipopt);
    return parse_inner_ip;
}
parser parse_inner_ip {
    extract(inner_ipv4);
    return parse_tcp;
}
parser parse_tcp {
    extract(tcp);
    return ingress;
}
parser parse_ipv4 {
    extract(ipv4);
    return select(ipv4.protocol) {
        4: parse_mplb_ipopt;
        default: parse_tcp;
    }
}


action _drop() {
    drop();
}

header_type hash_metadata_t {
    fields {
        mplb_hash : 32;
        mplb_hash_modulo : 32;
        recirculate_flag : 8;
    }
}
header_type routing_metadata_t {
    fields {
        nhop_ipv4 : 32;
    }
}

metadata routing_metadata_t routing_metadata;
metadata hash_metadata_t hash_metadata;

action set_nhop(nhop_ipv4, port) {
    modify_field(routing_metadata.nhop_ipv4, nhop_ipv4);
    modify_field(standard_metadata.egress_port, port);
    add_to_field(ipv4.ttl, -1);
}
action set_dst_mplb_port(dst)
{
    add_header(inner_ipv4);
    modify_field(inner_ipv4.protocol, ipv4.protocol);
    modify_field(inner_ipv4.ihl, ipv4.ihl);
    modify_field(inner_ipv4.diffserv, ipv4.diffserv);
    modify_field(inner_ipv4.totalLen, ipv4.totalLen);
    modify_field(inner_ipv4.identification, ipv4.identification);
    modify_field(inner_ipv4.flags, ipv4.flags);
    modify_field(inner_ipv4.fragOffset, ipv4.fragOffset);
    modify_field(inner_ipv4.ttl, ipv4.ttl);
    modify_field(inner_ipv4.version, ipv4.version);
    modify_field(inner_ipv4.srcAddr, ipv4.srcAddr);
    modify_field(inner_ipv4.dstAddr, ipv4.dstAddr);

    modify_field(ipv4.ihl, 5);
    add_to_field(ipv4.totalLen, 20);
    modify_field(ipv4.protocol, 4);
    modify_field(ipv4.srcAddr, ipv4.dstAddr);
    modify_field(ipv4.dstAddr, dst);

}
action set_dst(dst, pdip, ts) {
      //  version : 4;
      //  ihl : 4;
      //  diffserv : 8;
      //  totalLen : 16;
      //  identification : 16;
      //  flags : 3;
      //  fragOffset : 13;
      //  ttl : 8;
      //  protocol : 8;
      //  hdrChecksum : 16;
      //  srcAddr : 32;
      //  dstAddr: 32;
    //add_header(mplb);
    //add_to_field(ipv4.totalLen, 0x000b);
    //modify_field(ipv4.ihl, 0x8);
    //modify_field(mplb.tip, 0x83);
    //modify_field(mplb.lengt, 0x000b);
    //modify_field(mplb.pointer, 0x04);
    //modify_field(mplb.clientip, ipv4.srcAddr);
    //modify_field(mplb.virtualip, ipv4.dstAddr);
    add_header(mplb_ipopt);
    add_header(inner_ipv4);
    modify_field(inner_ipv4.version, ipv4.version);
    modify_field(inner_ipv4.protocol, ipv4.protocol);
    modify_field(inner_ipv4.ihl, ipv4.ihl);
    modify_field(inner_ipv4.diffserv, ipv4.diffserv);
    modify_field(inner_ipv4.totalLen, ipv4.totalLen);
    modify_field(inner_ipv4.identification, ipv4.identification);
    modify_field(inner_ipv4.flags, ipv4.flags);
    modify_field(inner_ipv4.fragOffset, ipv4.fragOffset);
    modify_field(inner_ipv4.ttl, ipv4.ttl);
    modify_field(inner_ipv4.protocol, ipv4.protocol);
    modify_field(inner_ipv4.srcAddr, ipv4.srcAddr);
    modify_field(inner_ipv4.dstAddr, ipv4.dstAddr);
    //modify_field(inner_ipv4.dstAddr, hash_metadata.mplb_hash);

    modify_field(mplb_ipopt.class, 3);
    modify_field(mplb_ipopt.number, 1);
    modify_field(mplb_ipopt.ts, ts);
    modify_field(mplb_ipopt.pdip, pdip);
    modify_field(mplb_ipopt.len, 16);

    modify_field(ipv4.ihl, 8);
    //add_to_field(ipv4.totalLen, 28);
    add_to_field(ipv4.totalLen, 36);
    modify_field(ipv4.protocol, 4);
    modify_field(ipv4.srcAddr, ipv4.dstAddr);
    modify_field(ipv4.dstAddr, dst);
    //modify_field(ipv4.srcAddr, mplb.virtualip);
}
table mplb_port {
    reads {
        tcp.dstPort : exact;
    }
    actions {
        set_dst_mplb_port;
        _drop;
    }
    size: 65536;
}

table modulo {
    reads {
        hash_metadata.mplb_hash : exact;
    }
    actions { 
        calc_modulo;
    }
    size : 10;
}

table mplb {
    reads {
        hash_metadata.mplb_hash_modulo : exact;
    }
    actions { 
        set_dst;
        _drop;
    }
    size: 1024;
    // Used to be: size: <?php echo $_GET['ring_size'] ?>;
}

table gen {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        set_gen;
    }
    size:2;
}

action set_gen(gen)  {
    modify_field(mplb_ipopt.gen, gen);
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

        //ipv4.dstAddr;
        //ipv4.srcAddr;
        //ipv4.protocol;
action calc_modulo() {
    //modify_field(hash_metadata.mplb_hash_modulo, (tcp.dstPort ^ tcp.srcPort ^
    //ipv4.dstAddr ^ ipv4.srcAddr ^ ipv4.protocol) % 10);
    //Used to be: modify_field(hash_metadata.mplb_hash_modulo, hash_metadata.mplb_hash %
    //<?php echo $_GET['ring_size'] ?>);
    modify_field(hash_metadata.mplb_hash_modulo, hash_metadata.mplb_hash, 10);
}
action set_dmac(dmac) {
    modify_field(ethernet.dstAddr, dmac);
}

table recirc {
    reads {
        ipv4.srcAddr : exact;
    }
    actions {
        _recirculate;
    }
    size:2;
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

action _recirculate() {
    modify_field(standard_metadata.egress_port, standard_metadata.ingress_port);
    recirculate(recirc_FL);
}

action rewrite_mac(smac) {
    modify_field(ethernet.srcAddr, smac);
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
    if (standard_metadata.instance_type == 0)
    {
        apply(recirc);
    }
    else
    {
        if(valid(ipv4) and ipv4.ttl > 0) {
            if (tcp.dstPort < 1024)
            {
                apply(modulo);
                apply(gen);
                apply(mplb);
            }
            else 
            {
                apply(mplb_port);
            }
            apply(ipv4_lpm);
            apply(forward);
        }
    }
}

control egress {
    apply(send_frame);
}

 
