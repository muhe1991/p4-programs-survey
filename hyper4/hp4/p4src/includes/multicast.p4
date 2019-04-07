/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

multicast.p4: Provide multicast support.  The method is less efficient than
              a switch-specific mechanism, but it is portable.  The code
              here sets up multicasting, while hp4.p4 is where it is carried
              out.
*/

action a_multicast(seq_id, highport) {
  modify_field(meta_ctrl.multicast_seq_id, seq_id);
  modify_field(meta_ctrl.multicast_current_egress, highport);
  modify_field(meta_ctrl.mc_flag, 1);
  modify_field(standard_metadata.egress_spec, highport);
}

table t_multicast_11 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_12 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_13 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_14 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_15 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_16 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_17 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_18 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_19 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_21 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_22 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_23 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_24 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_25 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_26 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_27 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_28 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_29 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_31 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_32 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_33 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_34 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_35 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_36 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_37 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_38 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_39 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_41 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_42 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_43 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_44 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_45 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_46 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_47 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_48 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

table t_multicast_49 {
  reads {
    meta_ctrl.program : exact;
  }
  actions {
    a_multicast;
  }
}

control do_multicast_11 {
  apply(t_multicast_11);
}

control do_multicast_12 {
  apply(t_multicast_12);
}

control do_multicast_13 {
  apply(t_multicast_13);
}

control do_multicast_14 {
  apply(t_multicast_14);
}

control do_multicast_15 {
  apply(t_multicast_15);
}

control do_multicast_16 {
  apply(t_multicast_16);
}

control do_multicast_17 {
  apply(t_multicast_17);
}

control do_multicast_18 {
  apply(t_multicast_18);
}

control do_multicast_19 {
  apply(t_multicast_19);
}

control do_multicast_21 {
  apply(t_multicast_21);
}

control do_multicast_22 {
  apply(t_multicast_22);
}

control do_multicast_23 {
  apply(t_multicast_23);
}

control do_multicast_24 {
  apply(t_multicast_24);
}

control do_multicast_25 {
  apply(t_multicast_25);
}

control do_multicast_26 {
  apply(t_multicast_26);
}

control do_multicast_27 {
  apply(t_multicast_27);
}

control do_multicast_28 {
  apply(t_multicast_28);
}

control do_multicast_29 {
  apply(t_multicast_29);
}

control do_multicast_31 {
  apply(t_multicast_31);
}

control do_multicast_32 {
  apply(t_multicast_32);
}

control do_multicast_33 {
  apply(t_multicast_33);
}

control do_multicast_34 {
  apply(t_multicast_34);
}

control do_multicast_35 {
  apply(t_multicast_35);
}

control do_multicast_36 {
  apply(t_multicast_36);
}

control do_multicast_37 {
  apply(t_multicast_37);
}

control do_multicast_38 {
  apply(t_multicast_38);
}

control do_multicast_39 {
  apply(t_multicast_39);
}

control do_multicast_41 {
  apply(t_multicast_41);
}

control do_multicast_42 {
  apply(t_multicast_42);
}

control do_multicast_43 {
  apply(t_multicast_43);
}

control do_multicast_44 {
  apply(t_multicast_44);
}

control do_multicast_45 {
  apply(t_multicast_45);
}

control do_multicast_46 {
  apply(t_multicast_46);
}

control do_multicast_47 {
  apply(t_multicast_47);
}

control do_multicast_48 {
  apply(t_multicast_48);
}

control do_multicast_49 {
  apply(t_multicast_49);
}
