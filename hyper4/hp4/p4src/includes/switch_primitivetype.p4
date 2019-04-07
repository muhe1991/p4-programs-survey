/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

switch_primitivetype.p4: Redirect execution to the control function appropriate
                         for the next primitive in the target P4 program
*/

#include "modify_field.p4"
#include "add_header.p4"
#include "copy_header.p4"
#include "remove_header.p4"
#include "push.p4"
#include "pop.p4"
#include "drop.p4"
#include "multicast.p4"
#include "math_on_field.p4"
#include "truncate.p4"


control switch_primitivetype_11 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) { //_condition_25
    do_modify_field_11();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_11();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_11();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_11();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_11();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_11();
  }
}

control switch_primitivetype_12 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_12();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_12();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_12();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_12();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_12();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_12();
  }
}

control switch_primitivetype_13 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_13();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_13();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_13();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_13();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_13();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_13();
  }
}

control switch_primitivetype_14 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_14();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_14();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_14();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_14();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_14();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_14();
  }
}

control switch_primitivetype_15 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_15();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_15();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_15();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_15();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_15();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_15();
  }
}

control switch_primitivetype_16 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_16();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_16();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_16();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_16();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_16();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_16();
  }
}

control switch_primitivetype_17 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_17();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_17();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_17();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_17();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_17();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_17();
  }
}

control switch_primitivetype_18 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_18();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_18();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_18();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_18();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_18();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_18();
  }
}

control switch_primitivetype_19 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_19();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_19();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_19();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_19();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_19();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_19();
  }
}

control switch_primitivetype_21 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_21();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_21();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_21();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_21();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) { //_condition_109
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_21();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_21();
  }
}

control switch_primitivetype_22 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_22();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_22();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_22();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_22();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_22();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_22();
  }
}

control switch_primitivetype_23 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_23();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_23();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_23();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_23();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_23();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_23();
  }
}

control switch_primitivetype_24 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_24();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_24();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_24();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_24();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_24();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_24();
  }
}

control switch_primitivetype_25 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_25();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_25();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_25();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_25();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_25();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_25();
  }
}

control switch_primitivetype_26 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_26();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_26();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_26();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_26();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_26();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_26();
  }
}

control switch_primitivetype_27 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_27();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_27();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_27();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_27();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_27();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_27();
  }
}

control switch_primitivetype_28 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_28();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_28();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_28();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_28();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_28();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_28();
  }
}

control switch_primitivetype_29 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_29();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_29();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_29();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_29();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_29();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_29();
  }
}

control switch_primitivetype_31 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_31();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_31();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_31();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_31();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_31();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_31();
  }
}

control switch_primitivetype_32 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_32();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_32();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_32();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_32();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_32();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_32();
  }
}

control switch_primitivetype_33 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_33();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_33();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_33();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_33();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_33();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_33();
  }
}

control switch_primitivetype_34 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_34();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_34();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_34();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_34();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_34();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_34();
  }
}

control switch_primitivetype_35 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_35();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_35();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_35();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_35();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_35();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_35();
  }
}

control switch_primitivetype_36 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_36();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_36();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_36();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_36();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_36();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_36();
  }
}

control switch_primitivetype_37 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_37();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_37();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_37();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_37();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_37();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_37();
  }
}

control switch_primitivetype_38 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_38();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_38();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_38();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_38();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_38();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_38();
  }
}

control switch_primitivetype_39 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_39();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_39();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_39();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_39();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_39();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_39();
  }
}

control switch_primitivetype_41 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_41();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_41();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_41();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_41();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_41();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_41();
  }
}

control switch_primitivetype_42 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_42();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_42();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_42();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_42();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_42();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_42();
  }
}

control switch_primitivetype_43 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_43();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_43();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_43();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_43();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_43();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_43();
  }
}

control switch_primitivetype_44 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_44();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_44();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_44();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_44();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_44();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_44();
  }
}

control switch_primitivetype_45 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_45();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_45();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_45();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_45();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_45();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_45();
  }
}

control switch_primitivetype_46 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_46();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_46();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_46();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_46();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_46();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_46();
  }
}

control switch_primitivetype_47 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_47();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_47();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_47();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_47();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_47();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_47();
  }
}

control switch_primitivetype_48 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_48();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_48();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_48();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_48();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_48();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_48();
  }
}

control switch_primitivetype_49 {
  if(meta_primitive_state.primitive == A_MODIFY_FIELD) {
    do_modify_field_49();
  }
  else if(meta_primitive_state.primitive == A_ADD_HEADER) {
    do_add_header_49();
  }
  else if(meta_primitive_state.primitive == A_TRUNCATE) {
    do_truncate_49();
  }
  else if(meta_primitive_state.primitive == A_DROP) {
    do_drop_49();
  }
  else if(meta_primitive_state.primitive == A_NO_OP) {
  }
  else if(meta_primitive_state.primitive == A_MULTICAST) {
    do_multicast_49();
  }
  else if(meta_primitive_state.primitive == A_MATH_ON_FIELD) {
    do_math_on_field_49();
  }
}
