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

#ifndef HYPERV_METADTA_
#define HYPERV_METADTA_

/****************************************************
 * vdp_metadata_t
 * Vritual data plane metadata for control and stage
 ***************************************************/
header_type vdp_metadata_t {
	fields {
		// Identifiers
		vdp_id     : 16; 
		inst_id    : 8 ;
		stage_id   : 8 ;

		// Action block variables
		action_chain_id		: 48; 
		action_chain_bitmap : 48;
		
		// Match block variable
		match_chain_result  : 48;
		match_chain_bitmap  : 3 ;

		recirculation_flag    : 1 ;      
		remove_or_add_flag  : 1 ;
		mod_flag			: 1 ;
	}
}

metadata vdp_metadata_t vdp_metadata;

/****************************************************
 * user_metadata_t
 * Reserved meta-data for programs
 ***************************************************/
header_type user_metadata_t {
	fields {
		meta : 256;
		load_header  : 800;
	}
}

metadata user_metadata_t user_metadata;

/****************************************************
 * context_metadata_t
 * Context data and intermediate variables for \
 * arithmetical logic
 ***************************************************/
header_type context_metadata_t {
	fields {
		r1 : 16;
		r2 : 16;
		r3 : 16;
		r4 : 16;
		r5 : 32;
		op          : 2  ;
		left_expr   : 16 ;
		right_expr  : 16 ;
		count 	    : 32 ;
		hash        : 32 ;
		hash_header : 800;
	}
}

metadata context_metadata_t context_metadata;

#endif