/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

math_on_field.p4: Implements HP4 support for doing math to a field.
*/

// emask ensures change is isolated to the desired field
action a_add2f_extracted_const_s(val, leftshift, emask) {
  modify_field(extracted.data, (extracted.data & ~emask) | ( extracted.data + (val << leftshift) ));
}

// faster and easier, but no protection
action a_add2f_extracted_const_u(val, leftshift) {
  modify_field(extracted.data, extracted.data + (val << leftshift) );
}

// emask ensures change is isolated to the desired field
action a_subff_extracted_const_s(val, leftshift, emask) {
  modify_field(extracted.data, (extracted.data & ~emask) | ( extracted.data + (val << leftshift) ));
}

// faster and easier, but no protection
action a_subff_extracted_const_u(val, leftshift) {
  modify_field(extracted.data, extracted.data - (val << leftshift) );
}

table t_math_on_field_11 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_12 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_13 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_14 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_15 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_16 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_17 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_18 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_add2f_extracted_const_u;
    a_subff_extracted_const_s;
    a_subff_extracted_const_u;
  }
}

table t_math_on_field_19 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_21 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_22 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_23 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_24 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_25 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_26 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_27 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_28 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_29 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_31 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_32 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_33 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_34 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_35 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_36 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_37 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_38 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_39 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_41 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_42 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_43 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_44 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_45 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_46 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_47 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_48 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

table t_math_on_field_49 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.subtype : exact;
    meta_primitive_state.match_ID : exact;
  }
  actions {
    a_add2f_extracted_const_s;
    a_subff_extracted_const_s;
  }
}

control do_math_on_field_11 {
  apply(t_math_on_field_11);
}

control do_math_on_field_12 {
  apply(t_math_on_field_12);
}

control do_math_on_field_13 {
  apply(t_math_on_field_13);
}

control do_math_on_field_14 {
  apply(t_math_on_field_14);
}

control do_math_on_field_15 {
  apply(t_math_on_field_15);
}

control do_math_on_field_16 {
  apply(t_math_on_field_16);
}

control do_math_on_field_17 {
  apply(t_math_on_field_17);
}

control do_math_on_field_18 {
  apply(t_math_on_field_18);
}

control do_math_on_field_19 {
  apply(t_math_on_field_19);
}

control do_math_on_field_21 {
  apply(t_math_on_field_21);
}

control do_math_on_field_22 {
  apply(t_math_on_field_22);
}

control do_math_on_field_23 {
  apply(t_math_on_field_23);
}

control do_math_on_field_24 {
  apply(t_math_on_field_24);
}

control do_math_on_field_25 {
  apply(t_math_on_field_25);
}

control do_math_on_field_26 {
  apply(t_math_on_field_26);
}

control do_math_on_field_27 {
  apply(t_math_on_field_27);
}

control do_math_on_field_28 {
  apply(t_math_on_field_28);
}

control do_math_on_field_29 {
  apply(t_math_on_field_29);
}

control do_math_on_field_31 {
  apply(t_math_on_field_31);
}

control do_math_on_field_32 {
  apply(t_math_on_field_32);
}

control do_math_on_field_33 {
  apply(t_math_on_field_33);
}

control do_math_on_field_34 {
  apply(t_math_on_field_34);
}

control do_math_on_field_35 {
  apply(t_math_on_field_35);
}

control do_math_on_field_36 {
  apply(t_math_on_field_36);
}

control do_math_on_field_37 {
  apply(t_math_on_field_37);
}

control do_math_on_field_38 {
  apply(t_math_on_field_38);
}

control do_math_on_field_39 {
  apply(t_math_on_field_39);
}

control do_math_on_field_41 {
  apply(t_math_on_field_41);
}

control do_math_on_field_42 {
  apply(t_math_on_field_42);
}

control do_math_on_field_43 {
  apply(t_math_on_field_43);
}

control do_math_on_field_44 {
  apply(t_math_on_field_44);
}

control do_math_on_field_45 {
  apply(t_math_on_field_45);
}

control do_math_on_field_46 {
  apply(t_math_on_field_46);
}

control do_math_on_field_47 {
  apply(t_math_on_field_47);
}

control do_math_on_field_48 {
  apply(t_math_on_field_48);
}

control do_math_on_field_49 {
  apply(t_math_on_field_49);
}
