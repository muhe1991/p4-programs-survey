/*
table ext_debug_256 {
  reads {
    bitfield_256 : valid;
  }
  actions {
    _no_op;
  }
}

table ext_debug_512 {
  reads {
    bitfield_512 : valid;
  }
  actions {
    _no_op;
  }
}

table ext_debug_768 {
  reads {
    bitfield_768 : valid;
  }
  actions {
    _no_op;
  }
}
*/

/*
table t_meta_parse_debug {
  reads {
    meta_parse.debug : exact;
  }
  actions {
    _no_op;
  }
}
*/

table t_debug_extracted {
  reads {
    extracted.data : ternary;
  }
  actions {
    _no_op;
  }
}

table extracted_debug_exact {
  reads {
    extracted.data : exact;
  }
  actions {
    _no_op;
  }
}
