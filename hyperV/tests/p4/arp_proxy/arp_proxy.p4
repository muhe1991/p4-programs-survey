header_type ethernet_t {
  fields {
    dest : 48;
    src : 48;
    etherType : 16;
  }
}

header_type arp_t {
  fields {
    hw_type : 16;
    prot_type : 16;
    hw_size : 8;
    prot_size : 8;
    opcode : 16;
    sender_MAC : 48;
    sender_IP : 32;
    target_MAC : 48;
    target_IP : 32;
  } 
}

header ethernet_t ethernet;
header arp_t arp;

parser start {
  extract(ethernet);
  return select(ethernet.etherType) {
    0x0806 : parse_arp;
    default : ingress;
  }
}

parser parse_arp {
  extract(arp);
  return ingress;
}

action a_init_meta_egress(port) {
  modify_field(standard_metadata.egress_spec, port);
}

table init_meta_egress {
  reads {
    standard_metadata.ingress_port : exact;
  }
  actions {
    a_init_meta_egress;
  }
}

action arp_present() {
}

table check_arp {
  reads {
    arp : valid;
  }
  actions {
    arp_present;
    send_packet;
  }
}

action arp_request() {
}

table check_opcode {
  reads {
    arp.opcode : exact;
  }
  actions {
    arp_request;
    send_packet;
  }
}

action arp_reply(IP, MAC) {
  modify_field(standard_metadata.egress_spec, standard_metadata.ingress_port);
  
  modify_field(arp.targest_MAC, arp.sender_MAC);
  modify_field(arp.target_IP, arp.send_ip);
  modify_field(ethernet.dest, ethernet.src);

  modify_field(arp.sender_MAC, MAC);
  modify_field(arp.sender_IP, IP);
  modify_field(ethernet.src, MAC);
  modify_field(arp.opcode, 2);
}

table handle_arp_request {
  reads {
    arp.target_IP : exact;
  }
  actions {
    arp_reply;
    send_packet;
  }
}

// action_ID: 5
action send_packet() {
  
}


control ingress {
  apply(init_meta_egress);
  apply(check_arp) {
    arp_present {
      apply(check_opcode) {
        arp_request {
          apply(handle_arp_request);
        }
      }
    }
  }
}