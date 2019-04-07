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

#ifndef HYPERVISOR_TEMPLATE
#define HYPERVISOR_TEMPLATE

#include "define.p4"

//---------------------------------------------------------------------------
/*
 * In the match pipeline, we classify the match fields in a standard match-
 * action table into three types: packet header, standard metadata and user-
 * defined matadata. The fourth table maps the combined result to an action
 * bitmap. In this way we avoid using an exceedingly large match filed in one
 * table to reduce TCAM pressure. A match bitmap is also used to indicate whe-
 * ther a table should be executed or skipped in a match pipeline.
 */
#define STAGE(X)															\
control match_action_##X {		                                          	\
	if (vdp_metadata.match_chain_bitmap & BIT_MASK_HEADER    != 0) {     	\
		apply(table_header_match_##X);                                      \
	}                                                                       \
	if (vdp_metadata.match_chain_bitmap & BIT_MASK_STD_META  != 0) {     	\
		apply(table_std_meta_match_##X);                                    \
	}                                                                       \
	if (vdp_metadata.match_chain_bitmap & BIT_MASK_USER_META != 0) {     	\
		apply(table_user_meta_##X);                                         \
	}																		\
	if (MATCH_RESULT != 0) {												\
		apply(table_match_result_##X);										\
	}																		\
	if (ACTION_BITMAP != 0)	{												\
		execute_do_##X();													\
    }						                                                \
}                                                                           \
table table_header_match_##X {                                              \
	reads {                                                                 \
		vdp_metadata.inst_id : exact ;                                		\
		vdp_metadata.stage_id : exact ;                                  	\
		user_metadata.load_header : ternary ;                             	\
	}                                                                       \
	actions { 																\
		set_match_result; 												\
		set_action_id;														\
		set_next_stage;													\
		set_action_id_direct;												\
		end;																\
		set_match_result_with_next_stage;								\
	}    									                                \
}                                                                           \
table table_std_meta_match_##X {                                            \
	reads{                                                                  \
		vdp_metadata.inst_id : exact ;                                		\
		vdp_metadata.stage_id : exact ;                                  	\
		standard_metadata.ingress_port : ternary ;                          \
		standard_metadata.egress_spec : ternary ;                           \
		standard_metadata.instance_type : ternary ;                         \
	}                                                                       \
	actions { 																\
		set_match_result; 												\
		set_action_id;														\
		set_next_stage;													\
		end;																\
		set_action_id_direct;												\
		set_match_result_with_next_stage;								\
	}									                                    \
}                                                                           \
table table_user_meta_##X {	                                                \
	reads {                             				                    \
		vdp_metadata.inst_id 		: exact ;       				        \
		vdp_metadata.stage_id 		: exact ;   	               			\
		user_metadata.meta 	        : ternary;	            				\
	}                                                       				\
	actions { 																\
		set_match_result;												\
		set_action_id; 														\
		set_action_id_direct;												\
		set_next_stage;													\
		set_match_result_with_next_stage;								\
		end;																\
	}                    													\
}                                                           				\
table table_match_result_##X {                                				\
	reads {																	\
		MATCH_RESULT 	: exact;         									\
	}                                                       				\
	actions {																\
		set_action_id_direct; 												\ 
		set_stage_and_bitmap; 												\
		set_next_stage;														\
	}                														\
}                                                           				


//---------------------------------------------------------------------------
/* Stages can branch to another stage depending on the result of a boolean 
 * expression.
 * table_get_expression_x is used to calculate all types of boolean expressions
 * e.g. header <|=|> const, header <|=|> header, header <|=|> meta
 * counter can only be compared with const?
 */
#define CONDITIONAL_STAGE(X)												\
control conditional_##X {		    										\
	apply(table_get_expression_##X);										\
	if (context_metadata.left_expr < context_metadata.right_expr) {			\
		apply(table_branch_1_##X);											\
	} 																		\
	else if(context_metadata.left_expr > context_metadata.right_expr) {		\
		apply(table_branch_2_##X);										    \	
	} 																		\
	else {																	\
		apply(table_branch_3_##X);											\
	}																		\
}																			\
table table_get_expression_##X {											\
	reads {																	\
		vdp_metadata.inst_id : exact ;										\
		vdp_metadata.stage_id : exact ;										\
	}																		\
	actions {																\
		set_expr_header_op_const;										\
		set_expr_header_op_header;										\
		set_expr_header_op_meta;											\
		set_expr_meta_op_const;											\
		set_expr_meta_op_header;											\
		set_expr_meta_op_meta;											\
		set_expr_counter_op_const;										\
	}																		\
}																			\
table table_branch_1_##X {													\
	reads {																	\
		vdp_metadata.inst_id : exact ;										\
		vdp_metadata.stage_id : exact ;										\
	}																		\
	actions { 																\
		set_next_stage; 													\
		set_match_result;												\
		set_action_id; 														\
		set_next_stage;													\
		end;																\
	}																		\
}																			\
table table_branch_2_##X {													\
	reads {																	\
		vdp_metadata.inst_id : exact ;										\
		vdp_metadata.stage_id : exact ;										\
	}																		\
	actions { 																\
		set_next_stage;													\
		set_match_result;												\
		set_action_id; 														\
		set_next_stage;													\
		end;																\
	}																		\
}																			\
table table_branch_3_##X {													\
	reads {																	\
		vdp_metadata.inst_id : exact ;										\
		vdp_metadata.stage_id : exact ;										\
	}																		\
	actions { 																\
		set_next_stage;													\
		set_match_result;												\
		set_action_id; 														\
		set_next_stage;													\
		end;																\
	}																		\
}																			


//-----------------------------------------------------------------------
/* 
 * 
 */
#define EXECUTE_ACTION(X)												\
control execute_do_##X {												\
	if ((ACTION_BITMAP & BIT_MASK_MOD_HEADER_WITH_META) != 0) {			\
		apply(table_mod_header_with_meta_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_META_WITH_META) != 0) {			\
		apply(table_mod_meta_with_meta_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_HEADER_WITH_HEADER) != 0) {		\
		apply(table_mod_header_with_header_##X);						\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_META_WITH_HEADER) != 0) {			\
		apply(table_mod_meta_with_header_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_HEADER_WITH_CONST) != 0) {		\
		apply(table_mod_header_with_const_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_META_WITH_CONST) != 0) {			\
		apply(table_mod_meta_with_const_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_ADD_HEDAER) != 0) {					\
		apply(table_add_header_##X);									\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_REMOVE_HEADER) != 0) {				\
		apply(table_remove_header_##X);									\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_STD_META) != 0) {					\
		apply(table_mod_std_meta_##X);									\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_GENERATE_DIGIST) != 0) {			    \
		apply(table_generate_digest_##X);								\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_ADD ) != 0) {							\
		apply(table_add_##X);											\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_SUBTRACT ) != 0) {					\
		apply(table_subtract_##X);										\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_REGISTER) != 0) {						\
		apply(table_register_##X);										\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_COUNTER) != 0) {						\
		apply(table_counter_##X);										\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_HASH) != 0) {							\
	    apply(table_hash_##X);											\
	}																	\				
	if ((ACTION_BITMAP & BIT_MASK_PROFILE) != 0) {						\
	    apply(table_action_profile_##X);								\
	}																	\
}																		\
table table_add_##X {													\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_add_header_with_const;									\
		do_add_meta_with_const;										\
		do_add_header_with_header;									\
		do_add_meta_with_header;									\
		do_add_header_with_meta;									\
		do_add_meta_with_meta;										\
	}																	\
}																		\
table table_generate_digest_##X {										\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_gen_digest;												\
	}																	\
}																		\
table table_subtract_##X {												\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_subtract_const_from_header;									\
		do_subtract_const_from_meta;									\
		do_subtract_header_from_header;									\
		do_subtract_header_from_meta;									\
		do_subtract_meta_from_header;									\
		do_subtract_meta_from_meta;										\
	}																	\
}																		\
table table_mod_std_meta_##X {											\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_std_meta;												\
		do_loopback;													\
		do_forward;														\
		do_queue;														\
		do_drop;														\
		do_multicast;													\
	}																	\
}																		\
table table_mod_header_with_const_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_header_with_const;									\
		do_mod_header_with_const_and_checksum;						\
	}																	\
}																		\
table table_mod_meta_with_const_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_meta_with_const;										\
	}																	\
}																		\
table table_mod_header_with_meta_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_header_with_meta_1;									\
		do_mod_header_with_meta_2;									\
		do_mod_header_with_meta_3;									\
	}																	\
}																		\
table table_mod_meta_with_meta_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_meta_with_meta_1;									\
		do_mod_meta_with_meta_2;									\
		do_mod_meta_with_meta_3;									\
	}																	\
}																		\
table table_mod_header_with_header_##X {								\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_header_with_header_1;								\
		do_mod_header_with_header_2;								\
		do_mod_header_with_header_3;								\
	}																	\
}																		\
table table_mod_meta_with_header_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_mod_meta_with_header_1;									\
		do_mod_meta_with_header_2;									\
		do_mod_meta_with_header_3;									\
	}																	\
}																		\
table table_add_header_##X {											\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_add_header_1;											\
	}																	\
}																		\	
table table_remove_header_##X {											\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_remove_header_1;												\
	}																	\
}																		\
table table_hash_##X {													\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_hash_crc16;													\
		do_hash_crc32;													\	
	}																	\
}																		\
table table_action_profile_##X {   										\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	action_profile : hash_profile;  									\
}																		\
table table_counter_##X {												\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		packet_count;													\
		packet_count_clear;												\
	}																	\
}																		\
table table_register_##X {												\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		do_load_register_into_header;									\
		do_load_register_into_meta;										\
		do_write_header_into_register;									\
		do_wirte_meta_into_register;									\
		do_wirte_const_into_register;									\
	}																	\
}																		\
counter counter_##X {													\
 	type : packets_and_bytes;											\
	direct : table_counter_##X;											\
}																		


#endif