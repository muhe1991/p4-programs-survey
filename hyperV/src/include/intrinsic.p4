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

/**
 * queuing_metadata_t
 * Metadata related metadata.
 */
header_type queueing_metadata_t {
    fields {
        enq_timestamp : 48;
        enq_qdepth    : 16;
        deq_timedelta : 32;
        deq_qdepth    : 16;
    }
}

metadata queueing_metadata_t queueing_metadata;


/**
 * intrinsic_metadata_t
 * Predefined metadate related with targets.
 */
header_type intrinsic_metadata_t {
    fields {
        ingress_global_timestamp : 48;
        lf_field_list            : 8 ;
        mcast_grp                : 16;
        egress_rid               : 16;
        resubmit_flag            : 8 ;
        recirculate_flag         : 8 ;
        qid                      : 8 ;
    }
}

metadata intrinsic_metadata_t intrinsic_metadata;