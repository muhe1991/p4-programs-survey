/* Copyright 2016-present NetArch Lab, Tsinghua University.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//***********************************************************
//				       HyperV primitives
//***********************************************************

/**
 * No operation.
 */
action noop() {

}

/**
 * Count packets with global register.
 * @param index <> packet counter index.
 */
action packet_count(index) {
	register_read(context_metadata.count, global_register, index);
	register_write(global_register,  // Global register 
				   index, 
				   context_metadata.count + 1);
}

/**
 * Clear packet counter.
 * @param index <> pakcet counter index
 */ 
action packet_count_clear(index) {
	register_write(global_register, index, 0);
}

/**
 * Loop back packets.
 */
action do_loopback() {
	modify_field(standard_metadata.egress_spec, 
		standard_metadata.ingress_port);
}


/**
 * Set the multicast group.
 * @param mcast_grp <> multicast group ID. 
 */
action do_multicast(mcast_grp) {
	modify_field(intrinsic_metadata.mcast_grp, mcast_grp);
}

/**
 * Set the queue id.
 * @param qid <> queue id
 */
action do_queue(qid) {
	modify_field(intrinsic_metadata.qid, qid);
}

/**
 * Forward packets
 * @param port  destination ports
 */ 
action do_forward(port) {
	modify_field(standard_metadata.egress_spec, port);
}

/**
 * Drop packets.
 */
action do_drop() {
	drop();
} 


/**
 * Generate digest to the CPU receiver.
 * @param receiver
 */
action do_gen_digest(receiver) {
	generate_digest(receiver, digest_list);
}


/**
 * Add header fileds with const integers.
 * @param value1 <header length> value of the const.
 * @param mask1 <header length> value mask.
 */ 
action do_add_header_with_const(value1, mask1) {
	bit_or(HDR, HDR & (~mask1),
		(HDR + value1) & mask1);
}

/**
 * Add user-defined metadata with const integers.
 * @param value1 <metadata length> value of the const.
 * @param mask1 <metadata length> value mask.
 */ 
action do_add_meta_with_const(value1, mask1) {
	bit_or(META, META & (~mask1),
		(META + value1) & mask1);
}

/**
 * Add header with the header values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_add_header_with_header(left1, 
								 right1, 
								 mask1) {
	bit_or(HDR, HDR & (~mask1), 
		(HDR + (((HDR<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Add user defiend metadata with the header values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_add_meta_with_header(left1, 
                               right1, 
                               mask1) {
	bit_or(META, META & (~mask1), 
		(META + (((HDR<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Add header with the metadata values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_add_header_with_meta(left1, 
							   right1, 
							   mask1) {
	bit_or(HDR, HDR & (~mask1), 
		(HDR + (((META<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Add metadata with the metadata values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_add_meta_with_meta(left1, 
							 right1, 
							 mask1) {
	bit_or(META, META & (~mask1), 
		(META + (((META<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Substract header with the const values.
 * @param value1 <header length> the const value
 * @param mask1 <header length> value mask
 */
action do_subtract_const_from_header(value1, mask1) {
	bit_or(HDR, HDR & (~mask1), 
		(HDR - value1) & mask1);
}

/**
 * Substract metadata with the const values.
 * @param value1 <header length> the const value
 * @param mask1 <header length> value mask
 */
action do_subtract_const_from_meta(value1, mask1) {
	bit_or(META, META & (~mask1), 
		(META - value1) & mask1);
}

/**
 * Substract header with the header values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_subtract_header_from_header(left1, 
									  right1, 
									  mask1) {
	bit_or(HDR, HDR & (~mask1), 
		(HDR - (((HDR<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Substract header with the metadata values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_subtract_header_from_meta(left1, 
									right1, 
									mask1) {
	bit_or(META, META & (~mask1), 
		(META - (((HDR<<left1)>>right1)&mask1)) & mask1);
}


/**
 * Substract metadata with the header values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_subtract_meta_from_header(left1, right1, mask1) {
	bit_or(HDR, HDR & (~mask1), 
		(HDR - (((META<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Substract metadata with the metadata values.
 * @param left1 <header length> left shift
 * @param right1 <header length>  right shift
 * @param mask1 <header length> value mask
 */
action do_subtract_meta_from_meta(left1, right1, mask1) {
	bit_or(META, META & (~mask1), 
		(META - (((META<<left1)>>right1)&mask1)) & mask1);
}

/**
 * Add a header into the packet.
 * @param value <header length> left shift
 * @param mask1  <header length> value mask
 * @param mask2  <header length> value mask
 * @param length1 <header length> header length
 */
action do_add_header_1(value,
					   mask1, 
					   mask2, 
					   length1) {
	push(byte_stack, length1*1);

	bit_or(HDR, HDR & mask1, 
		(HDR & (~mask1) )>>(length1*8));
	add_to_field(HEADER_LENGTH, length1);
	do_mod_header_with_const(value, mask2);
	modify_field(desc_hdr.len, HEADER_LENGTH);
	
	modify_field(REMOVE_OR_ADD_FLAG, 1);
	modify_field(MOD_FLAG, 1);
}

/**
 * Remove a header form the packet.
 * @param value1 <header length> left shift
 * @param mask1  <header length> value mask
 * @param mask2  <header length> value mask
 * @param length1 <header length> header length
 */
action do_remove_header_1(mask1, mask2, length1) {
	push(byte_stack, length1*1);
	subtract_from_field(HEADER_LENGTH, length1);
	
	modify_field(byte_stack[0].byte, HEADER_FLAG);
	modify_field(byte_stack[1].byte, HEADER_LENGTH);
	modify_field(byte_stack[2].byte, (POLICY_ID>>16)&0xFF);
	modify_field(byte_stack[3].byte, (POLICY_ID) & 0xFF);

	remove_header(desc_hdr);

	bit_or(HDR, HDR & mask1, 
		(HDR & mask2)<<(length1*8));
	
	modify_field(REMOVE_OR_ADD_FLAG, 1);
	modify_field(MOD_FLAG, 1);
}

/**
 * Modify header with one const value.
 * @param value <header length> left shift
 * @param mask1  <header length> value mask
 * @param length1 <header length> value mask
 */
action do_mod_header_with_const(value, mask1) {
	bit_or(HDR, (HDR & (~mask1)), (value & mask1));
	modify_field(MOD_FLAG, 1);
}

/**
 * Modify header with one const value, meanwhile re-calculate the checksum (inline).
 * @param value1 <header length> left shift
 * @param mask1  <header length> value mask
 * @param length1 <header length> value mask
 */
action do_mod_header_with_const_and_checksum(value, 
										     mask1, 
										     value1, 
										     value2, 
										     offset1) {
	do_mod_header_with_const(value, mask1);
	do_update_transport_checksum(value1,
		 value2, offset1);
}

/**
 * Modify header with one const value, meanwhile re-calculate the checksum (inline).
 * @param value <header length>  the const value.
 * @param mask1  <header length> value mask
 */
action do_mod_meta_with_const(value, mask1) {
	bit_or(META, (META & ~mask1), 
		(value & mask1));
}

/**
 * Modify standard metadata fields.
 * @param val1  <>
 * @param mask1 <>
 * @param val2  <>
 * @param mask2 <>
 * @param val3  <>
 * @param mask3 <>
 * @param val4  <>
 * @param mask4 <>
 */
action do_mod_std_meta(val1, mask1, 
					   val2, mask2, 
					   val3, mask3, 
					   val4, mask4) {
	bit_or(standard_metadata.egress_spec, 
		standard_metadata.egress_spec & (~mask1), val1 & mask1);
	bit_or(standard_metadata.egress_port, 
		standard_metadata.egress_port & (~mask2), val2 & mask2);
	bit_or(standard_metadata.ingress_port, 
		standard_metadata.ingress_port & (~mask3), val3 & mask3);
	bit_or(standard_metadata.packet_length, 
		standard_metadata.packet_length & (~mask4), val4 & mask4);
}

/**
 * Modify header with the one metadata field.
 * @param value1 <header length> left shift
 * @param mask1  <header length> value mask
 * @param length1 <header length> value mask
 */
action do_mod_header_with_meta_1(left1, 
								 right1, 
								 mask1) {
    bit_or(HDR, (HDR & ~mask1),
		 (((META << left1) >> right1) & mask1));
	modify_field(MOD_FLAG, 1);
}

/**
 * Modify header with the two metadata fields.
 * @param left1  <header length> left shift
 * @param right1   <header length> right shift
 * @param mask1 <header length> value mask
 * @param left2  <header length> left shift
 * @param right2   <header length> right shift
 * @param mask2 <header length> value mask
 */
action do_mod_header_with_meta_2(left1, right1, mask1, 
								 left2, right2, mask2) {
    do_mod_header_with_meta_1(left1, right1, mask1);
	do_mod_header_with_meta_1(left2, right2, mask2);
}

/**
 * Modify header with the three metadata fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 * @param left3  	<header length> left shift
 * @param right3   	<header length> right shift
 * @param mask3 	<header length> value mask
 */
action do_mod_header_with_meta_3(left1, right1, mask1, 
								 left2, right2, mask2, 
								 left3, right3, mask3) {
    do_mod_header_with_meta_1(left1, right1, mask1);
	do_mod_header_with_meta_1(left2, right2, mask2);
	do_mod_header_with_meta_1(left3, right3, mask3);
}

/**
 * Modify metadata with the one metadata field.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 */
action do_mod_meta_with_meta_1(left1, right1, mask1) {
    bit_or(META, (META & ~mask1), 
		(((META << left1) >> right1) & mask1));
}

/**
 * Modify metadata with the two metadata fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 */
action do_mod_meta_with_meta_2(left1, right1, mask1, 
							   left2, right2, mask2) {
    do_mod_meta_with_meta_1(left1, right1, mask1);
	do_mod_meta_with_meta_1(left2, right2, mask2);
}

/**
 * Modify metadata with the three metadata fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 * @param left3  	<header length> left shift
 * @param right3   	<header length> right shift
 * @param mask3 	<header length> value mask
 */
action do_mod_meta_with_meta_3(left1, right1, mask1, 
							   left2, right2, mask2,
							   left3, right3, mask3) {
	do_mod_meta_with_meta_1(left1, right1, mask1);
	do_mod_meta_with_meta_1(left2, right2, mask2);
	do_mod_meta_with_meta_1(left3, right3, mask3);   
}

/**
 * Modify header with the one header field.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 */
action do_mod_header_with_header_1(left1, right1, mask1) {
    bit_or(META, (HDR & ~mask1), 
		(((HDR << left1) >> right1) & mask1));

	modify_field(MOD_FLAG, 1);
}

/**
 * Modify header with the three header fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 */
action do_mod_header_with_header_2(left1, right1, mask1, 
								   left2, right2, mask2) {
    do_mod_header_with_header_1(left1, right1, mask1);
	do_mod_header_with_header_1(left2, right2, mask2);
}

/**
 * Modify header with the three header fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 * @param left3  	<header length> left shift
 * @param right3   	<header length> right shift
 * @param mask3 	<header length> value mask
 */
action do_mod_header_with_header_3(left1, right1, mask1, 
								   left2, right2, mask2, 
								   left3, right3, mask3) {
    do_mod_header_with_header_1(left1, right1, mask1);
	do_mod_header_with_header_1(left2, right2, mask2);
	do_mod_header_with_header_1(left3, right3, mask3);
}

/**
 * Modify metadata with the one header field.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 */
action do_mod_meta_with_header_1(left1, right1, mask1) {
    bit_or(META, (HDR & ~mask1), 
		(((HDR << left1) >> right1) & mask1));
}

/**
 * Modify metadata with the two header fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 */
action do_mod_meta_with_header_2(left1, right1, mask1, 
								 left2, right2, mask2) {
    do_mod_meta_with_header_1(left1, right1, mask1);
	do_mod_meta_with_header_1(left2, right2, mask2);
}

/**
 * Modify metadata with the three header fields.
 * @param left1  	<header length> left shift
 * @param right1   	<header length> right shift
 * @param mask1 	<header length> value mask
 * @param left2  	<header length> left shift
 * @param right2   	<header length> right shift
 * @param mask2 	<header length> value mask
 * @param left3  	<header length> left shift
 * @param right3   	<header length> right shift
 * @param mask3 	<header length> value mask
 */
action do_mod_meta_with_header_3(left1, right1, mask1, 
				left2, right2, mask2, left3, right3, mask3) {
    do_mod_meta_with_header_1(left1, right1, mask1);
	do_mod_meta_with_header_1(left2, right2, mask2);
	do_mod_meta_with_header_1(left3, right3, mask3);
}


/**
 * Recirculate packets at  the egress pipeline.
 * @param progid Pragram ID
 */
action do_recirculate(progid) {
	modify_field(vdp_metadata.recirculation_flag, 1);
	modify_field(vdp_metadata.remove_or_add_flag, 0);
	modify_field(vdp_metadata.inst_id, progid); 
	recirculate( flInstance_with_umeta );
}

/**
 * Resubmit packet at the ingress pipeline.
 * @param progid Pragram ID
 */
action do_resubmit(progid) {
	modify_field(vdp_metadata.recirculation_flag, 1);
	modify_field(vdp_metadata.inst_id, progid);
	resubmit(flInstance_with_umeta);
}

/**
 * Load register value into the header.
 * @param index register index
 * @param left1 
 * @param mask1
 */
action do_load_register_into_header(index, 
 								    left1, 
 								    mask1) {
	register_read(context_metadata.r5, global_register, index);
	bit_or(HDR, HDR & (~mask1), 
		(context_metadata.r5<<left1) & mask1);

	modify_field(MOD_FLAG, 1);
}

/**
 * Load register value into the metadata.
 * @param index register index
 * @param left1 
 * @param mask1
 */
action do_load_register_into_meta(index, 
								  left1, 
								  mask1) {
	register_read(context_metadata.r5,  
	              global_register, 
	              index);
	bit_or(META, META & (~mask1), 
		(context_metadata.r5<<left1) & mask1);
}


/**
 * Load the header field into the register.
 * @param index register index
 * @param right1 
 * @param mask1
 */
action do_write_header_into_register(index, 
								     right1, 
								     mask1) {
	register_write(global_register, index, 
		(HDR>>right1) & mask1);
}

/**
 * Load the metadata field into the register.
 * @param index register index
 * @param left1 
 * @param mask1
 */
action do_wirte_meta_into_register(index, right1, mask1) {
	register_write(global_register, index, 
		(META>>right1) & mask1);
}

/**
 * Load the const value into the register.
 * @param index register index
 * @param value the const value to load
 */
action do_wirte_const_into_register(index, value) {
	register_write(global_register, index, value);
}

/**
 * Return the hash header.
 */
field_list hash_field_list {
	context_metadata.hash_header;
}

/**
 * Calculate the field list with CRC16 hash.
 */
field_list_calculation hash_crc16 {
    input {
        hash_field_list;
    }
    algorithm : crc16;
    output_width : 16;
}

/**
 * Calculate the field list with CRC32 hash.
 */
field_list_calculation hash_crc32 {
    input {
        hash_field_list;
    }
    algorithm : crc32;
    output_width : 32;
}

/**
 * Set the hash header.
 * @param hdr_mask 
 */
action do_set_hash_hdr(hdr_mask) {
	modify_field(context_metadata.hash_header, HDR & hdr_mask);
}


/**
 * Calculate CRC16.
 */
action do_hash_crc16(hdr_mask) {
	do_set_hash_hdr(hdr_mask);
	modify_field_with_hash_based_offset(context_metadata.hash, 0,
                                        hash_crc16, 65536);
}

/**
 * Calculate CRC32.
 */
action do_hash_crc32(hdr_mask) {
	do_set_hash_hdr(hdr_mask);
	modify_field_with_hash_based_offset(context_metadata.hash, 0,
                                        hash_crc32, 0xFFFFFFFF);
}

/**
 * Select hash profile.
 */
action_profile hash_profile {
	actions {
		do_forward;
		noop;
	}

	dynamic_action_selection : hash_action_selector;
}

/**
 * Perform hash calculation.
 */
field_list_calculation hash_calculation { 
	input {	
		hash_field_list; 
	}
	algorithm : crc16; 
	output_width : 16;
}

/**
 * Select hash action.
 */
action_selector hash_action_selector {
	selection_key : hash_calculation;
}
