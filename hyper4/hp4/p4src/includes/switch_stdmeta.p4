/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

switch_stdmeta.p4: Handles table matching: exact, using standard metadata
*/


table t1_stdmeta_ingress_port {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.ingress_port : exact;
  }
  actions {
    init_program_state;
  }
}

table t1_stdmeta_packet_length {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.packet_length : exact;
  }
  actions {
    init_program_state;
  }
}

table t1_stdmeta_instance_type {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.instance_type : exact;
  }
  actions {
    init_program_state;
  }
}

table t1_stdmeta_egress_spec {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.egress_spec : exact;
  }
  actions {
    init_program_state;
  }
}

table t2_stdmeta_ingress_port {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.ingress_port : exact;
  }
  actions {
    init_program_state;
  }
}

table t2_stdmeta_packet_length {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.packet_length : exact;
  }
  actions {
    init_program_state;
  }
}

table t2_stdmeta_instance_type {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.instance_type : exact;
  }
  actions {
    init_program_state;
  }
}

table t2_stdmeta_egress_spec {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.egress_spec : exact;
  }
  actions {
    init_program_state;
  }
}

table t3_stdmeta_ingress_port {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.ingress_port : exact;
  }
  actions {
    init_program_state;
  }
}

table t3_stdmeta_packet_length {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.packet_length : exact;
  }
  actions {
    init_program_state;
  }
}

table t3_stdmeta_instance_type {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.instance_type : exact;
  }
  actions {
    init_program_state;
  }
}

table t3_stdmeta_egress_spec {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.egress_spec : exact;
  }
  actions {
    init_program_state;
  }
}

table t4_stdmeta_ingress_port {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.ingress_port : exact;
  }
  actions {
    init_program_state;
  }
}

table t4_stdmeta_packet_length {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.packet_length : exact;
  }
  actions {
    init_program_state;
  }
}

table t4_stdmeta_instance_type {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.instance_type : exact;
  }
  actions {
    init_program_state;
  }
}

table t4_stdmeta_egress_spec {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.egress_spec : exact;
  }
  actions {
    init_program_state;
  }
}


control switch_stdmeta_1 {
  if(meta_ctrl.stdmeta_ID == STDMETA_INGRESS_PORT) {  //_condition_20
    apply(t1_stdmeta_ingress_port);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_PACKET_LENGTH) {
    apply(t1_stdmeta_packet_length);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_INSTANCE_TYPE) {
    apply(t1_stdmeta_instance_type);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_EGRESS_SPEC) {
    apply(t1_stdmeta_egress_spec);
  }
}

control switch_stdmeta_2 {
  if(meta_ctrl.stdmeta_ID == STDMETA_INGRESS_PORT) {
    apply(t2_stdmeta_ingress_port);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_PACKET_LENGTH) {
    apply(t2_stdmeta_packet_length);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_INSTANCE_TYPE) {
    apply(t2_stdmeta_instance_type);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_EGRESS_SPEC) {
    apply(t2_stdmeta_egress_spec);
  }
}

control switch_stdmeta_3 {
  if(meta_ctrl.stdmeta_ID == STDMETA_INGRESS_PORT) {
    apply(t3_stdmeta_ingress_port);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_PACKET_LENGTH) {
    apply(t3_stdmeta_packet_length);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_INSTANCE_TYPE) {
    apply(t3_stdmeta_instance_type);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_EGRESS_SPEC) {
    apply(t3_stdmeta_egress_spec);
  }
}

control switch_stdmeta_4 {
  if(meta_ctrl.stdmeta_ID == STDMETA_INGRESS_PORT) {
    apply(t4_stdmeta_ingress_port);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_PACKET_LENGTH) {
    apply(t4_stdmeta_packet_length);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_INSTANCE_TYPE) {
    apply(t4_stdmeta_instance_type);
  }
  else if(meta_ctrl.stdmeta_ID == STDMETA_EGRESS_SPEC) {
    apply(t4_stdmeta_egress_spec);
  }
}
