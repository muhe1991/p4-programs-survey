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


/****************************************************
 * description_header_t
 * Descripe packet headers
 ***************************************************/
header_type description_hdr_t {
	fields {
		flag		: 8 ;
		len         : 8 ;
		vdp_id      : 16;
		load_header : * ;
	}

	length : len;
	max_length : 128;
}

header description_hdr_t desc_hdr;

/****************************************************
 * byte_stack_t
 * Used for add_headers, remove_header, push, and \
 * pop operations
 ***************************************************/
header_type byte_stack_t {
	fields {
		byte : 8;
	}
}

header byte_stack_t byte_stack[64];