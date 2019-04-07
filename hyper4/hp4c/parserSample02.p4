header_type ext_t {
  fields {
    data : 8;
  }
}

header ext_t ext[100];

parser start {
  extract(ext[next]);
  return select(ext[0]) {
    0x00: p_A;
    0x01: p_B;
    default: ingress;
  }
}

parser p_A {
  extract(ext[next]);
  return p_C;
}

parser p_B {
  return select(current(0, 8)) {
    0x00: p_C;
    default: ingress;
  }
}

parser p_C {
  extract(ext[next]);
  return ingress;
}

control ingress {
}

/*
Say we have 'real' headers P, Q, R, each one byte.
After start, we have header P.  Based on the value of the single field within
P, we proceed to p_A or p_B.
In p_A, we extract Q.
In p_B, we extract nothing.
In p_C, we extract R.  But mapping R to the correct element in ext depends on
whether the preceding state was p_A or p_B.  If p_A, R is at ext[2].  If p_B,
R is at ext[1].
But notice how because of p_B's current expression in its return statement,
when running in HyPer4, we arrive at p_C with the same number of bits extracted.
To solve this, we can represent each parse_node with multiple IDs, each
corresponding to a different path.
The implication is that we will need multiple entries for a tset_inspect_XX_XX
table to represent a select statement in a parse state, where each entry shifts
the values to look for to different ext elements, as required by each path
preceding the parse state.  What's more, the shift may cross tset_inspect_XX_XX
boundaries.
I worry, too, about maintaining the ext -> represented header field mapping for
use by the ingress pipeline.  We may need to add one more match parameter to
each table: the final parse ID.  This parse ID may serve as a lookup into a
conceptual data structure storing all possible mappings.
By doing this, we multiply the number of table entries required.
*/
