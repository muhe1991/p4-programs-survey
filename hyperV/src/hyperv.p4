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

#include "include/intrinsic.p4"
#include "include/define.p4"
#include "include/action.p4"
#include "include/config.p4"
#include "include/stateful.p4"
#include "include/control.p4"
#include "include/headers.p4"
#include "include/field-lists.p4"
#include "include/metadata.p4"
#include "include/template.p4"
#include "include/execute.p4"
#include "include/checksum.p4"
#include "include/parser.p4"

//--------------------------------ingress--------------------------
control ingress {
	if (PROG_ID == 0) {
		apply(table_config_at_initial);
	}
	if (PROG_ID != 0 and PROG_ID != 0xFF) {
		//--------------------stage 1-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_1) {
			conditional_stage1();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_1) {
			match_action_stage1();
		}
		
		//--------------------stage 2-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_2) {
			conditional_stage2();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_2) {
			match_action_stage2();
		}

		//--------------------stage 3-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_3) {
			conditional_stage3();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_3) {
			match_action_stage3();
		}

		//--------------------stage 4-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_4) {
			conditional_stage4();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_4) {
			match_action_stage4();
		}

		//--------------------stage 5-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_5) {
			conditional_stage5();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_5) {
			match_action_stage5();
		}
		
		//--------------------stage 6-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_6) {
			conditional_stage6();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_6) {
			match_action_stage6();
		}

		//--------------------stage 7-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_7) {
			conditional_stage7();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_7) {
			match_action_stage7();
		}

		//--------------------stage 8-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_8) {
			conditional_stage8();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_8) {
			match_action_stage8();
		}

				//--------------------stage 8-----------------
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
											CONST_CONDITIONAL_STAGE_9) {
			conditional_stage9();
		}
		if (((vdp_metadata.stage_id & CONST_NUM_OF_STAGE)) == 
														CONST_STAGE_9) {
			match_action_stage9();
		}
		
		
		if ((REMOVE_OR_ADD_HEADER == 0) and (PROG_ID != 0xFF)) {
			apply(table_config_at_end);
		}
	}
}

//---------conditional stage 1-------------------------
CONDITIONAL_STAGE(stage1)

//---------conditional stage 2-------------------------
CONDITIONAL_STAGE(stage2)

//---------conditional stage 3-------------------------
CONDITIONAL_STAGE(stage3)

//---------conditional stage 4-------------------------
CONDITIONAL_STAGE(stage4)
//---------conditional stage 1-------------------------
CONDITIONAL_STAGE(stage5)

//---------conditional stage 2-------------------------
CONDITIONAL_STAGE(stage6)

//---------conditional stage 3-------------------------
CONDITIONAL_STAGE(stage7)

//---------conditional stage 4-------------------------
CONDITIONAL_STAGE(stage8)

//---------conditional stage 4-------------------------
CONDITIONAL_STAGE(stage9)

//---------stage 1--------------------------------------
STAGE(stage1)

//---------stage 2--------------------------------------
STAGE(stage2)

//---------stage 3--------------------------------------
STAGE(stage3)

//---------stage 4--------------------------------------
STAGE(stage4)

//---------stage 5--------------------------------------
STAGE(stage5)

//---------stage 6--------------------------------------
STAGE(stage6)

//---------stage 7--------------------------------------
STAGE(stage7)

//---------stage 8--------------------------------------
STAGE(stage8)

//---------stage 8--------------------------------------
STAGE(stage9)

//------------------------egress-----------------------
control egress {
	if (REMOVE_OR_ADD_HEADER == 1) {
		apply(table_config_at_egress);
	} 
	else if (MOD_FLAG == 1) {
		recalculate_checksum();
		apply(dh_deparse);
	}
}