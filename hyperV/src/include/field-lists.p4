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

#ifndef HYPERVISOR_INSTANCE
#define HYPERVISOR_INSTANCE

#include "config.p4"



/****************************************************
 * Metadata instances
 ***************************************************/

/****************************************************
 * Field list for resubmit and recirculate
 ***************************************************/
field_list flInstance_with_umeta { 
    vdp_metadata;
    user_metadata;
    standard_metadata; 
}

field_list digest_list {
    META;
    standard_metadata;
}

field_list watch_digist_list {
	LOAD_HEADER;
}

field_list debug_digist_list {
	USER_META;
	LOAD_HEADER;
}


#endif