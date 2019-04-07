/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

match.p4: Support various types of matching used by the target P4 program.
*/

#include "switch_stdmeta.p4"

action init_program_state(action_ID, match_ID, next_table) {
  modify_field(meta_primitive_state.action_ID, action_ID);
  modify_field(meta_primitive_state.match_ID, match_ID);
  modify_field(meta_primitive_state.primitive_index, 1);
  modify_field(meta_ctrl.next_table, next_table);
}

action set_meta_stdmeta(stdmeta_ID) {
  modify_field(meta_ctrl.stdmeta_ID, stdmeta_ID);
}


table t1_extracted_exact {
  reads {
    meta_ctrl.program : exact;
    extracted.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t1_metadata_exact {
  reads {
    meta_ctrl.program : exact;
    tmeta.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t1_stdmeta_exact {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    set_meta_stdmeta;
  }
}

table t1_extracted_valid {
  reads {
    meta_ctrl.program : exact;
    extracted.validbits : ternary;
  }
  actions {
    init_program_state;
  }
}

table t2_extracted_exact {
  reads {
    meta_ctrl.program : exact;
    extracted.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t2_metadata_exact {
  reads {
    meta_ctrl.program : exact;
    tmeta.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t2_stdmeta_exact {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    set_meta_stdmeta;
  }
}

table t2_extracted_valid {
  reads {
    meta_ctrl.program : exact;
    extracted.validbits : ternary;
  }
  actions {
    init_program_state;
  }
}

table t3_extracted_exact {
  reads {
    meta_ctrl.program : exact;
    extracted.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t3_metadata_exact {
  reads {
    meta_ctrl.program : exact;
    tmeta.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t3_stdmeta_exact {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    set_meta_stdmeta;
  }
}

table t3_extracted_valid {
  reads {
    meta_ctrl.program : exact;
    extracted.validbits : ternary;
  }
  actions {
    init_program_state;
  }
}

table t4_extracted_exact {
  reads {
    meta_ctrl.program : exact;
    extracted.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t4_metadata_exact {
  reads {
    meta_ctrl.program : exact;
    tmeta.data : ternary;
  }
  actions {
    init_program_state;
  }
}

table t4_stdmeta_exact {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    set_meta_stdmeta;
  }
}

table t4_extracted_valid {
  reads {
    meta_ctrl.program : exact;
    extracted.validbits : ternary;
  }
  actions {
    init_program_state;
  }
}

control match_1 {
  if(meta_ctrl.next_table == EXTRACTED_EXACT) { //_condition_17
    apply(t1_extracted_exact);
  }
  else if(meta_ctrl.next_table == METADATA_EXACT) { //_condition_18
    apply(t1_metadata_exact);
  }
  else if(meta_ctrl.next_table == STDMETA_EXACT) { //_condition_19
    apply(t1_stdmeta_exact);
    switch_stdmeta_1();
  }
  else if(meta_ctrl.next_table == EXTRACTED_VALID) {
    apply(t1_extracted_valid);
  }
}

control match_2 {
  if(meta_ctrl.next_table == EXTRACTED_EXACT) {
    apply(t2_extracted_exact);
  }
  else if(meta_ctrl.next_table == METADATA_EXACT) {
    apply(t2_metadata_exact);
  }
  else if(meta_ctrl.next_table == STDMETA_EXACT) {
    apply(t2_stdmeta_exact);
    switch_stdmeta_2();
  }
  else if(meta_ctrl.next_table == EXTRACTED_VALID) {
    apply(t2_extracted_valid);
  }
}

control match_3 {
  if(meta_ctrl.next_table == EXTRACTED_EXACT) {
    apply(t3_extracted_exact);
  }
  else if(meta_ctrl.next_table == METADATA_EXACT) {
    apply(t3_metadata_exact);
  }
  else if(meta_ctrl.next_table == STDMETA_EXACT) {
    apply(t3_stdmeta_exact);
    switch_stdmeta_3();
  }
  else if(meta_ctrl.next_table == EXTRACTED_VALID) {
    apply(t3_extracted_valid);
  }
}

control match_4 {
  if(meta_ctrl.next_table == EXTRACTED_EXACT) {
    apply(t4_extracted_exact);
  }
  else if(meta_ctrl.next_table == METADATA_EXACT) {
    apply(t4_metadata_exact);
  }
  else if(meta_ctrl.next_table == STDMETA_EXACT) {
    apply(t4_stdmeta_exact);
    switch_stdmeta_4();
  }
  else if(meta_ctrl.next_table == EXTRACTED_VALID) {
    apply(t4_extracted_valid);
  }
}
