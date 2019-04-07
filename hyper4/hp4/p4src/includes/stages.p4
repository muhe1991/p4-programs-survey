/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

stages.p4: Each control function executes a single match-action stage of a
           target P4 program.

           The set_program_state tables guide execution from one primtive to
           the next.
*/

#include "match.p4"
#include "action.p4"
#include "switch_primitivetype.p4"

action set_program_state(action_ID, primitive_index, stage_state, next_stage) {
  modify_field(meta_primitive_state.action_ID, action_ID);
  modify_field(meta_primitive_state.primitive_index, primitive_index);
  modify_field(meta_ctrl.stage_state, stage_state);
  modify_field(meta_ctrl.next_stage, next_stage);
}

table set_program_state_11 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_12 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_13 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_14 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_15 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_16 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_17 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_18 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_19 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_21 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_22 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_23 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_24 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_25 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_26 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_27 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_28 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_29 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_31 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_32 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_33 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_34 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_35 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_36 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_37 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_38 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_39 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_41 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_42 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_43 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_44 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_45 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_46 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_47 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_48 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

table set_program_state_49 {
  reads {
    meta_ctrl.program : exact;
    meta_primitive_state.action_ID : exact;
    meta_primitive_state.primitive_index : exact;
  }
  actions {
    set_program_state;
  }
}

control stage1 {
  match_1();
  apply(set_primitive_metadata_11);
  switch_primitivetype_11();
  apply(set_program_state_11);
  if(meta_ctrl.stage_state != COMPLETE) {
    apply(set_primitive_metadata_12);
    switch_primitivetype_12();
    apply(set_program_state_12);
    if(meta_ctrl.stage_state != COMPLETE) {
      apply(set_primitive_metadata_13);
      switch_primitivetype_13();
      apply(set_program_state_13);
      if(meta_ctrl.stage_state != COMPLETE) {
        apply(set_primitive_metadata_14);
        switch_primitivetype_14();
        apply(set_program_state_14);
        if(meta_ctrl.stage_state != COMPLETE) {
          apply(set_primitive_metadata_15);
          switch_primitivetype_15();
          apply(set_program_state_15);
          if(meta_ctrl.stage_state != COMPLETE) {
            apply(set_primitive_metadata_16);
            switch_primitivetype_16();
            apply(set_program_state_16);
            if(meta_ctrl.stage_state != COMPLETE) {
              apply(set_primitive_metadata_17);
              switch_primitivetype_17();
              apply(set_program_state_17);
              if(meta_ctrl.stage_state != COMPLETE) {
                apply(set_primitive_metadata_18);
                switch_primitivetype_18();
                apply(set_program_state_18);
                if(meta_ctrl.stage_state != COMPLETE) {
                  apply(set_primitive_metadata_19);
                  switch_primitivetype_19();
                  apply(set_program_state_19);
                }
              }
            }
          }
        }
      }
    }
  }
}

control stage2 {
  match_2();
  apply(set_primitive_metadata_21);
  switch_primitivetype_21();
  apply(set_program_state_21);
  if(meta_ctrl.stage_state != COMPLETE) {
    apply(set_primitive_metadata_22);
    switch_primitivetype_22();
    apply(set_program_state_22);
    if(meta_ctrl.stage_state != COMPLETE) {
      apply(set_primitive_metadata_23);
      switch_primitivetype_23();
      apply(set_program_state_23);
      if(meta_ctrl.stage_state != COMPLETE) {
        apply(set_primitive_metadata_24);
        switch_primitivetype_24();
        apply(set_program_state_24);
        if(meta_ctrl.stage_state != COMPLETE) {
          apply(set_primitive_metadata_25);
          switch_primitivetype_25();
          apply(set_program_state_25);
          if(meta_ctrl.stage_state != COMPLETE) {
            apply(set_primitive_metadata_26);
            switch_primitivetype_26();
            apply(set_program_state_26);
            if(meta_ctrl.stage_state != COMPLETE) {
              apply(set_primitive_metadata_27);
              switch_primitivetype_27();
              apply(set_program_state_27);
              if(meta_ctrl.stage_state != COMPLETE) {
                apply(set_primitive_metadata_28);
                switch_primitivetype_28();
                apply(set_program_state_28);
                if(meta_ctrl.stage_state != COMPLETE) {
                  apply(set_primitive_metadata_29);
                  switch_primitivetype_29();
                  apply(set_program_state_29);
                }
              }
            }
          }
        }
      }
    }
  }
}

control stage3 {
  match_3();
  apply(set_primitive_metadata_31);
  switch_primitivetype_31();
  apply(set_program_state_31);
  if(meta_ctrl.stage_state != COMPLETE) {
    apply(set_primitive_metadata_32);
    switch_primitivetype_32();
    apply(set_program_state_32);
    if(meta_ctrl.stage_state != COMPLETE) {
      apply(set_primitive_metadata_33);
      switch_primitivetype_33();
      apply(set_program_state_33);
      if(meta_ctrl.stage_state != COMPLETE) {
        apply(set_primitive_metadata_34);
        switch_primitivetype_34();
        apply(set_program_state_34);
        if(meta_ctrl.stage_state != COMPLETE) {
          apply(set_primitive_metadata_35);
          switch_primitivetype_35();
          apply(set_program_state_35);
          if(meta_ctrl.stage_state != COMPLETE) {
            apply(set_primitive_metadata_36);
            switch_primitivetype_36();
            apply(set_program_state_36);
            if(meta_ctrl.stage_state != COMPLETE) {
              apply(set_primitive_metadata_37);
              switch_primitivetype_37();
              apply(set_program_state_37);
              if(meta_ctrl.stage_state != COMPLETE) {
                apply(set_primitive_metadata_38);
                switch_primitivetype_38();
                apply(set_program_state_38);
                if(meta_ctrl.stage_state != COMPLETE) {
                  apply(set_primitive_metadata_39);
                  switch_primitivetype_39();
                  apply(set_program_state_39);
                }
              }
            }
          }
        }
      }
    }
  }
}

control stage4 {
  match_4();
  apply(set_primitive_metadata_41);
  switch_primitivetype_41();
  apply(set_program_state_41);
  if(meta_ctrl.stage_state != COMPLETE) {
    apply(set_primitive_metadata_42);
    switch_primitivetype_42();
    apply(set_program_state_42);
    if(meta_ctrl.stage_state != COMPLETE) {
      apply(set_primitive_metadata_43);
      switch_primitivetype_43();
      apply(set_program_state_43);
      if(meta_ctrl.stage_state != COMPLETE) {
        apply(set_primitive_metadata_44);
        switch_primitivetype_44();
        apply(set_program_state_44);
        if(meta_ctrl.stage_state != COMPLETE) {
          apply(set_primitive_metadata_45);
          switch_primitivetype_45();
          apply(set_program_state_45);
          if(meta_ctrl.stage_state != COMPLETE) {
            apply(set_primitive_metadata_46);
            switch_primitivetype_46();
            apply(set_program_state_46);
            if(meta_ctrl.stage_state != COMPLETE) {
              apply(set_primitive_metadata_47);
              switch_primitivetype_47();
              apply(set_program_state_47);
              if(meta_ctrl.stage_state != COMPLETE) {
                apply(set_primitive_metadata_48);
                switch_primitivetype_48();
                apply(set_program_state_48);
                if(meta_ctrl.stage_state != COMPLETE) {
                  apply(set_primitive_metadata_49);
                  switch_primitivetype_49();
                  apply(set_program_state_49);
                }
              }
            }
          }
        }
      }
    }
  }
}

