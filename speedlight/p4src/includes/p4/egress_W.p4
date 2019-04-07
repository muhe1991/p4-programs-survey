/* Copyright 2018-present University of Pennsylvania
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
 * Tables and actions for the wraparound functions of the egress pipeline of
 * Speedlight.
 **/


#include "egress.p4"


/*==============================================================================
= Get Last Seen and Check Rollover                                             =
= Similar to ingress.  Fetches and updates the former last seen register, then =
= uses it to check if the neighbor's snapshot id has rolled over since the     =
= last time they sent us a message.                                            =
==============================================================================*/

/**
 * Get and update the last seen snapshot ID from my neighbor.
 *
 * Input: effective_port, snapshot_header.port_id, ipv4_option.option,
 *        snapshot_header.snapshot_id
 * Output: former_last_seen
 * Postcondition: reg_last_seen_in_egress[current_index] = snapshot_header.snapshot_id
 **/
table teUpdateLastSeen {
    reads {
        snapshot_metadata.effective_port: exact;
        snapshot_header.port_id : ternary;
        ipv4_option.option : ternary;
    }
    actions {
        aeUpdateLastSeen;
    }
    size : NEIGHBORS_TBL_SIZE_EGR;
}

action aeUpdateLastSeen(index_val) {
    reUpdateLastSeen(reg_last_seen_in_egress, index_val);
}

/**
 * See tiCheckRollover
 **/
table teCheckRollover {
    reads {
        snapshot_metadata.snapshot_feature : exact;
    }
    actions {
        aCheckRollover;
    }
    size : 2;
}


/*==============================================================================
= Set Snapshot Case                                                            =
= Similar to ingress.  Sets snapshot_case based on the current snapshot ID and =
= the packet's ID.  Only runs when the packet has a snapshot header and the ID =
= has not rolled over.                                                         =
==============================================================================*/

control ceSetSnapshotCaseNoRollover {
	/*
     * former_id = reg_snapshot_id_egress[effective_port]
     * if (former_id >= former_last_seen)
     *     // port's snapshot ID hasn't wrapped either.  compare normally
     *     if (snapshot_header.snapshot_id > former_id)
     *         reg_snapshot_id_egress[effective_port] = snapshot_header.snapshot_id
     * else
     *     // former_id has wrapped and it should win
     */
    apply(teUpdateSnapshotIdNoRollover);
    /*
     * switch_rollover_check = former_last_seen - former_id
     * switch_greater = former_id - snapshot_header.snapshot_id
     * packet_greater = snapshot_header.snapshot_id - former_id
     * snapshot_changed_check = snapshot_header.snapshot_id - former_last_seen
     */
    apply(teCheckSnapshotCaseNoRollover);
    /*
     * if (switch_rollover_check)
     *     // they rolled back, but we haven't yet
     *     snapshot_case = 2
     * else
     *     // neither of us has rolled back
     *     if (switch_greater == 0 and packet_greater == 0)
     *         snapshot_case = 0
     *     else if (switch_greater == 0)
     *         snapshot_case = 1
     *     else if (packet_greater == 0)
     *         snapshot_case = 2
     */
    apply(teSetSnapshotCaseNoRollover);
}

/**
 * STAGE 5
 * Loads and possibly updates our current snapshot ID.  This should only update
 * if the packet's snapshot ID is larger than our snapshot ID.
 *
 * Input: snapshot_metadata.effective_port
 * Output: metadata.former_id = reg_snapshot_id_egress[snapshot_metadata.effective_port]
 **/
@pragma stage 5
table teUpdateSnapshotIdNoRollover {
    actions { aeUpdateSnapshotIdNoRollover; }
    default_action: aeUpdateSnapshotIdNoRollover();
    size : 0;
}

action aeUpdateSnapshotIdNoRollover() {
    reUpdateSnapshotIdNoRollover(reg_snapshot_id_egress, snapshot_metadata.effective_port);
}

/**
 * See tiCheckSnapshotCaseNoRollover
 **/
table teCheckSnapshotCaseNoRollover {
    actions { aCheckSnapshotCaseRollover; }
    default_action: aCheckSnapshotCaseRollover();
    size : 0;
}

/**
 * See tiSetSnapshotCaseNoRollover
 **/
table teSetSnapshotCaseNoRollover {
    reads {
        snapshot_metadata.switch_rollover_check : ternary;
        snapshot_metadata.switch_greater : ternary;
        snapshot_metadata.packet_greater : ternary;
    }
    actions {
        aSetSnapshotCase;
    }
    size : 8;
}


/*==============================================================================
= Set Snapshot Case                                                            =
= Similar to ingress.  Sets snapshot_case based on the current snapshot ID and =
= the packet's ID.  Only runs when the packet has a snapshot header and the ID =
= has rolled over.                                                             =
==============================================================================*/

control ceSetSnapshotCaseRollover {
	/*
     * former_id = reg_snapshot_id_ingress[effective_port]
     * if (former_id < former_last_seen)
     *     // former_id wrapped too!  compare normally
     *     if (snapshot_header.snapshot_id > former_id)
     *         reg_snapshot_id_ingress[effective_port] = snapshot_header.snapshot_id
     * else
     *     // they haven't wrapped yet.  We should win
     */
    apply(teUpdateSnapshotIdRollover); // STAGE 5
    /*
     * switch_rollover_check = former_last_seen - former_id
     * switch_greater = former_id - snapshot_header.snapshot_id
     * packet_greater = snapshot_header.snapshot_id - former_id
     * snapshot_changed_check = snapshot_header.snapshot_id - former_last_seen
     */
    apply(teCheckSnapshotCaseRollover);
    /*
     * if (switch_rollover_check)
     *     if (switch_greater == 0 and packet_greater == 0)
     *         snapshot_case = 0
     *     else if (switch_greater == 0)
     *         snapshot_case = 1
     *     else if (packet_greater == 0)
     *         snapshot_case = 2
     * else
     *     // we rolled back but they haven't
     *     snapshot_case = 1
     */
    apply(teSetSnapshotCaseRollover);
}

/**
 * STAGE 5
 * See tiUpdateSnapshotIdRollover
 *
 * Input: snapshot_metadata.effective_port
 * Output: former_id = reg_snapshot_id_egress[snapshot_metadata.effective_port]
 * Postcondition: reg_snapshot_id_egress[snapshot_metadata.effective_port] is max seen
 *                snapshot ID including rollover
 **/
@pragma stage 5
table teUpdateSnapshotIdRollover {
    actions { aeUpdateSnapshotIdRollover; }
    default_action:aeUpdateSnapshotIdRollover();
    size : 0;
}

action aeUpdateSnapshotIdRollover() {
    reUpdateSnapshotIdRollover(reg_snapshot_id_egress, snapshot_metadata.effective_port);
}

/**
 * See tiCheckSnapshotCaseNoRollover
 **/
table teCheckSnapshotCaseRollover {
    actions { aCheckSnapshotCaseRollover; }
    default_action: aCheckSnapshotCaseRollover();
    size : 0;
}

/**
 * See tiSetSnapshotCaseRollover
 **/
table teSetSnapshotCaseRollover {
    reads {
        snapshot_metadata.switch_rollover_check : ternary;
        snapshot_metadata.switch_greater : ternary;
        snapshot_metadata.packet_greater : ternary;
    }
    actions {
        aSetSnapshotCase;
    }
    size : 8;
}
