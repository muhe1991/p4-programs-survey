/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

add_header.p4: Carry out the add_header primitive
*/

action a_addh(sz, offset, msk, vbits) {
  modify_field(extracted.data, (extracted.data & ~msk) | (extracted.data >> (sz * 8)) & (msk >> (offset * 8)));
  modify_field(parse_ctrl.numbytes, parse_ctrl.numbytes + sz);
  modify_field(extracted.validbits, extracted.validbits | vbits);
}

table t_addh_11 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_12 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_13 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_14 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_15 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_16 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_17 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_18 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_19 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_21 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_22 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_23 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_24 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_25 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_26 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_27 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_28 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_29 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_31 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_32 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_33 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_34 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_35 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_36 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_37 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_38 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_39 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_41 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_42 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_43 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_44 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_45 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_46 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_47 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_48 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

table t_addh_49 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    a_addh;
  }
}

control do_add_header_11 {
  apply(t_addh_11);
}

control do_add_header_12 {
  apply(t_addh_12);
}

control do_add_header_13 {
  apply(t_addh_13);
}

control do_add_header_14 {
  apply(t_addh_14);
}

control do_add_header_15 {
  apply(t_addh_15);
}

control do_add_header_16 {
  apply(t_addh_16);
}

control do_add_header_17 {
  apply(t_addh_17);
}

control do_add_header_18 {
  apply(t_addh_18);
}

control do_add_header_19 {
  apply(t_addh_19);
}

control do_add_header_21 {
  apply(t_addh_21);
}

control do_add_header_22 {
  apply(t_addh_22);
}

control do_add_header_23 {
  apply(t_addh_23);
}

control do_add_header_24 {
  apply(t_addh_24);
}

control do_add_header_25 {
  apply(t_addh_25);
}

control do_add_header_26 {
  apply(t_addh_26);
}

control do_add_header_27 {
  apply(t_addh_27);
}

control do_add_header_28 {
  apply(t_addh_28);
}

control do_add_header_29 {
  apply(t_addh_29);
}

control do_add_header_31 {
  apply(t_addh_31);
}

control do_add_header_32 {
  apply(t_addh_32);
}

control do_add_header_33 {
  apply(t_addh_33);
}

control do_add_header_34 {
  apply(t_addh_34);
}

control do_add_header_35 {
  apply(t_addh_35);
}

control do_add_header_36 {
  apply(t_addh_36);
}

control do_add_header_37 {
  apply(t_addh_37);
}

control do_add_header_38 {
  apply(t_addh_38);
}

control do_add_header_39 {
  apply(t_addh_39);
}

control do_add_header_41 {
  apply(t_addh_41);
}

control do_add_header_42 {
  apply(t_addh_42);
}

control do_add_header_43 {
  apply(t_addh_43);
}

control do_add_header_44 {
  apply(t_addh_44);
}

control do_add_header_45 {
  apply(t_addh_45);
}

control do_add_header_46 {
  apply(t_addh_46);
}

control do_add_header_47 {
  apply(t_addh_47);
}

control do_add_header_48 {
  apply(t_addh_48);
}

control do_add_header_49 {
  apply(t_addh_49);
}

