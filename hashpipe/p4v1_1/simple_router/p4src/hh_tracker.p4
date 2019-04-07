field_list hash_list {
    hh_meta.mKeyCarried;
}

field_list_calculation stage1_hash {
    input {
        hash_list;
    }
    algorithm : my_hash_1;
    output_width : 5;
}

field_list_calculation stage2_hash {
    input {
        hash_list;
    }
    algorithm : my_hash_2;
    output_width : 5;
}

header_type tracking_metadata_t {
    fields {
        bit<32> mKeyInTable;
        bit<32> mCountInTable;
        bit<5> mIndex;
        bit<1> mValid;
        bit<32> mKeyCarried;
        bit<32> mCountCarried;
        bit<32> mDiff;
    }
}

metadata tracking_metadata_t hh_meta;

register flow_tracker_stage1 {
    width: 32;
    static: track_stage1;
    instance_count: 32;
}

register packet_counter_stage1 {
    width: 32;
    static: track_stage1;
    instance_count: 32;
}

register valid_bit_stage1 {
    width: 1;
    static: track_stage1;
    instance_count: 32;
}

action do_stage1(){
    // first table stage
    hh_meta.mKeyCarried = ipv4.srcAddr;
    hh_meta.mCountCarried = 0;

    // hash using my custom function 
    modify_field_with_hash_based_offset(hh_meta.mIndex, 0, stage1_hash,
    32);

    // read the key and value at that location
    hh_meta.mKeyInTable = flow_tracker_stage1[hh_meta.mIndex];
    hh_meta.mCountInTable = packet_counter_stage1[hh_meta.mIndex];
    hh_meta.mValid = valid_bit_stage1[hh_meta.mIndex];

    // check if location is empty or has a differentkey in there
    hh_meta.mKeyInTable = (hh_meta.mValid == 0)? hh_meta.mKeyCarried : hh_meta.mKeyInTable;
    hh_meta.mDiff = (hh_meta.mValid == 0)? 0 : hh_meta.mKeyInTable - hh_meta.mKeyCarried;

    // update hash table
    flow_tracker_stage1[hh_meta.mIndex] = ipv4.srcAddr;
    packet_counter_stage1[hh_meta.mIndex] = ((hh_meta.mDiff == 0)?
    hh_meta.mCountInTable + 1 : 1);
    valid_bit_stage1[hh_meta.mIndex] = 1;

    // update metadata carried to the next table stage
    hh_meta.mKeyCarried = ((hh_meta.mDiff == 0) ? 0:
    hh_meta.mKeyInTable);
    hh_meta.mCountCarried = ((hh_meta.mDiff == 0) ? 0:
    hh_meta.mCountInTable);  
}

table track_stage1 {
    actions { do_stage1; }
    size: 0;
}

/********************** table stage 2 **************************/

register flow_tracker_stage2 {
    width: 32;
    static: track_stage2;
    instance_count: 32;
}

register packet_counter_stage2 {
    width: 32;
    static: track_stage2;
    instance_count: 32;
}

register valid_bit_stage2 {
    width: 1;
    static: track_stage2;
    instance_count: 32;
}

action do_stage2(){
    // hash using my custom function 
    modify_field_with_hash_based_offset(hh_meta.mIndex, 0, stage2_hash,
    32);

    // read the key and value at that location
    hh_meta.mKeyInTable = flow_tracker_stage2[hh_meta.mIndex];
    hh_meta.mCountInTable = packet_counter_stage2[hh_meta.mIndex];
    hh_meta.mValid = valid_bit_stage2[hh_meta.mIndex];

    // check if location is empty or has a differentkey in there
    hh_meta.mKeyInTable = (hh_meta.mValid == 0)? hh_meta.mKeyCarried : hh_meta.mKeyInTable;
    hh_meta.mDiff = (hh_meta.mValid == 0)? 0 : hh_meta.mKeyInTable - hh_meta.mKeyCarried;

    // update hash table
    flow_tracker_stage2[hh_meta.mIndex] = ((hh_meta.mDiff == 0)?
    hh_meta.mKeyInTable : ((hh_meta.mCountInTable <
    hh_meta.mCountCarried) ? hh_meta.mKeyCarried :
    hh_meta.mKeyInTable));

    packet_counter_stage2[hh_meta.mIndex] = ((hh_meta.mDiff == 0)?
    hh_meta.mCountInTable + hh_meta.mCountCarried :
    ((hh_meta.mCountInTable < hh_meta.mCountCarried) ?
    hh_meta.mCountCarried : hh_meta.mCountInTable));

    valid_bit_stage2[hh_meta.mIndex] = ((hh_meta.mValid == 0) ?
    ((hh_meta.mKeyCarried == 0) ? (bit<1>)0 : 1) : (bit<1>)1);

    // update metadata carried to the next table stage
    hh_meta.mKeyCarried = ((hh_meta.mDiff == 0) ? 0:
    hh_meta.mKeyInTable);
    hh_meta.mCountCarried = ((hh_meta.mDiff == 0) ? 0:
    hh_meta.mCountInTable);  
}

table track_stage2 {
    actions { do_stage2; }
    size: 0;
}
       
