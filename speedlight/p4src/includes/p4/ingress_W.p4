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
 * Tables and actions for the wraparound functions of the ingress pipeline of
 * Speedlight.
 **/


#include "ingress.p4"


/*==============================================================================
= Get Last Seen and Check Rollover                                             =
= Fetches and updates the former last seen register, then uses it to check if  =
= the neighbor's snapshot id has rolled over since the last time they sent us  =
= a message.                                                                   =
==============================================================================*/

/**
 * Get and update the last seen snapshot ID from my neighbor.  The index that
 * gets read and updated is given by:
 *
 * if (snapshot_feature = 2)
 *     current_index = (effective_port - 1) * 2
 * else
 *     current_index = (effective_port - 1) * 2 + 1
 *
 * 1 2 : 0
 * 1 1 : 1
 * 2 2 : 2
 * 2 1 : 3
 * 3 2 : 4
 * 3 1 : 5
 *
 * Input: effective_port, snapshot_feature, snapshot_header.snapshot_id
 * Output: former_last_seen
 * Postcondition: reg_last_seen_in_ingress[index] = snapshot_id
 */
table tiUpdateLastSeen {
    reads {
        snapshot_metadata.effective_port : ternary;
        snapshot_metadata.snapshot_feature : ternary;
    }
    actions {
        aiUpdateLastSeen;
    }
    size : TWO_X_PORTS;
}

action aiUpdateLastSeen(index_val) {
    riUpdateLastSeen(reg_last_seen_in_ingress, index_val);
}

/**
 * Computes helper values to check if the neighbor has rolled over its SS ID.
 *    Ex: former_last_seen = 1, snapshot_id = 1
 *        => snapshot_changed_check = 0, snapshot_rollover_check = 0
 *        former_last_seen = 3, snapshot_id = 4
 *        => snapshot_changed_check = 1, snapshot_rollover_check = 0
 *        former_last_seen = 256, snapshot_id = 0
 *        => snapshot_changed_check = -256, snapshot_rollover_check = 256
 *
 * Note that snapshot_header may not exist, but in such cases, we never use
 * these values.  This needs to be outside the if condition or else the compiler
 * won't be able to place it.
 *
 * Input: former_last_seen, snapshot_header.snapshot_id
 * Output: snapshot_changed_check, snapshot_rollover_check
 **/
table tiCheckRollover {
    reads {
        snapshot_metadata.snapshot_feature : exact;
    }
    actions {
        aCheckRollover;
    }
    size : 2;
}

action aCheckRollover() {
    subtract(snapshot_metadata.snapshot_changed_check,
             snapshot_header.snapshot_id, snapshot_metadata.former_last_seen);
    subtract(snapshot_metadata.snapshot_rollover_check,
             snapshot_metadata.former_last_seen, snapshot_header.snapshot_id);
}


/*==============================================================================
= Set Snapshot Case                                                            =
= Sets snapshot_case based on the current snapshot ID and the packet's ID.     =
= Only runs when the packet has a snapshot header and the ID has not rolled    =
= over.                                                                        =
==============================================================================*/

control ciSetSnapshotCaseNoRollover {
    /*
     * former_id = reg_snapshot_id_ingress[effective_port]
     * if (former_id >= former_last_seen)
     *     // port's snapshot ID hasn't wrapped either.  compare normally
     *     if (snapshot_header.snapshot_id > former_id)
     *         reg_snapshot_id_ingress[effective_port]
     *                 = snapshot_header.snapshot_id
     * else
     *     // former_id has wrapped and it should win
     */
    apply(tiUpdateSnapshotIdNoRollover); // STAGE 5
    /*
     * switch_rollover_check = former_last_seen - former_id
     * switch_greater = former_id - snapshot_header.snapshot_id
     * packet_greater = snapshot_header.snapshot_id - former_id
     * snapshot_changed_check = snapshot_header.snapshot_id - former_last_seen
     */
    apply(tiCheckSnapshotCaseNoRollover);
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
    apply(tiSetSnapshotCaseNoRollover);
}

/**
 * STAGE 5
 * Loads and possibly updates our current snapshot ID.  This should only update
 * if the packet's snapshot ID is further than our snapshot ID.
 *
 * former_id = reg_snapshot_id_ingress[effective_port]
 * if (former_id >= former_last_seen)
 *     // port's snapshot ID hasn't wrapped either.  compare normally
 *     if (snapshot_header.snapshot_id > former_id)
 *         reg_snapshot_id_ingress[effective_port] = snapshot_header.snapshot_id
 * else
 *     // former_id has wrapped and it should win
 *
 * Input: effective_port, snapshot_header.snapshot_id
 * Output: former_id = reg_snapshot_id_ingress[effective_port]
 * Postcondition: reg_snapshot_id_ingress[effective_port] =
 *                        max(snapshot_header.snapshot_id,
 *                        reg_snapshot_id_ingress[effective_port])
 *                includes wrapping/rollover
 **/
@pragma stage 5
table tiUpdateSnapshotIdNoRollover {
    actions { aiUpdateSnapshotIdNoRollover; }
    default_action: aiUpdateSnapshotIdNoRollover();
    size : 0;
}

action aiUpdateSnapshotIdNoRollover() {
    riUpdateSnapshotIdNoRollover(reg_snapshot_id_ingress,
                                 snapshot_metadata.effective_port);
}

/**
 * General calculations that doesn't fit anywhere else. This does 2 things:
 *     1. calculates the relationship between the packet's ID and the port's ID
 *     2. calculates IHL value after removal of TCP Options header.  This MUST
 *        be calculated indirectly like this or else the compiler will complain
 *        about dependencies
 *
 * Input: former_last_seen, former_id, snapshot_id
 **/
table tiCheckSnapshotCaseNoRollover {
    actions { aCheckSnapshotCaseRollover; }
    default_action: aCheckSnapshotCaseRollover();
    size : 0;
}

action aCheckSnapshotCaseRollover() {
    subtract(snapshot_metadata.switch_rollover_check,
             snapshot_metadata.former_last_seen, snapshot_metadata.former_id);
    subtract(snapshot_metadata.switch_greater,
             snapshot_metadata.former_id, snapshot_header.snapshot_id);
    subtract(snapshot_metadata.packet_greater,
             snapshot_header.snapshot_id, snapshot_metadata.former_id);
    subtract(snapshot_metadata.snapshot_changed_check,
             snapshot_header.snapshot_id, snapshot_metadata.former_last_seen);
    modify_field(snapshot_metadata.current_id, snapshot_metadata.former_id);
}

/**
 * Based on the difference between the node's snapshot ID and the packets
 * snapshot ID, decide what to do.  We will never see 1+ 1+ because it's
 * saturating.
 *
 * 0 0 0 = forward (0)
 * 0 0 1+ = new ss (1)
 * 0 1+ 0 = in flight (2)
 * 1+ _ _ = in flight (2) // switch has rolled back, but we haven't
 *
 * For new SS, a value above 1 indicates that we skipped a snapshot.  Rely on
 * the control plane to ignore any snapshot we skipped.  Just worry about the
 * next one.
 * For in flight, a value above 1 also indicates we missed a packet in a
 * previous snapshot.  That snapshot is now inconsistent.  Again, only worry
 * about the last snapshot and rely on the control plane to ignore any
 * inconsistent snapshots.
 *
 * Input: snapshot_metadata.switch_greater, snapshot_metadata.packet_greater
 * Output: snapshot_metadata.snapshot_on (see below)
 **/
table tiSetSnapshotCaseNoRollover {
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
= Sets snapshot_case based on the current snapshot ID and the packet's ID.     =
= Only runs when the packet has a snapshot header and the ID has rolled over.  =
==============================================================================*/

control ciSetSnapshotCaseRollover {
    /*
     * former_id = reg_snapshot_id_ingress[effective_port]
     * if (former_id < former_last_seen)
     *     // former_id wrapped too!  compare normally
     *     if (snapshot_header.snapshot_id > former_id)
     *         reg_snapshot_id_ingress[effective_port]
     *                 = snapshot_header.snapshot_id
     * else
     *     // they haven't wrapped yet.  We should win
     */
    apply(tiUpdateSnapshotIdRollover); // STAGE 5
    /*
     * switch_rollover_check = former_last_seen - former_id
     * switch_greater = former_id - snapshot_header.snapshot_id
     * packet_greater = snapshot_header.snapshot_id - former_id
     * snapshot_changed_check = snapshot_header.snapshot_id - former_last_seen
     */
    apply(tiCheckSnapshotCaseRollover);
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
    apply(tiSetSnapshotCaseRollover);
}

/**
 * STAGE 5
 * Loads and possibly updates our current snapshot ID.  This should only update
 * if the packet's snapshot ID is larger than our snapshot ID.
 *
 * former_id = reg_snapshot_id_ingress[effective_port]
 * if (former_id < former_last_seen)
 *     // port's snapshot ID wrapped too!  compare normally
 *     if (snapshot_header.snapshot_id > former_id)
 *         reg_snapshot_id_ingress[effective_port] = snapshot_header.snapshot_id
 * else
 *     // they haven't wrapped yet.  We should win
 *
 * Input: effective_port, snapshot_header.snapshot_id
 * Output: former_id = reg_snapshot_id_ingress[effective_port]
 * Postcondition: reg_snapshot_id_ingress[effective_port] =
 *                        max(snapshot_header.snapshot_id,
 *                        reg_snapshot_id_ingress[effective_port])
 *                includes wrapping/rollover
 **/
@pragma stage 5
table tiUpdateSnapshotIdRollover {
    actions { aiUpdateSnapshotIdRollover; }
    default_action: aiUpdateSnapshotIdRollover();
    size : 0;
}

action aiUpdateSnapshotIdRollover() {
    riUpdateSnapshotIdRollover(reg_snapshot_id_ingress,
                               snapshot_metadata.effective_port);
}

/**
 * See tiCheckSnapshotCaseNoRollover
 **/
table tiCheckSnapshotCaseRollover {
    actions { aCheckSnapshotCaseRollover; }
    default_action: aCheckSnapshotCaseRollover();
    size : 0;
}

/**
 * Similar to tiSetSnapshotCaseNoRollover, but we have rolled over.
 *
 * 0 _ _ = new ss (1) // switch has rolled back, but we haven't
 * 1+ 0 0 = forward (0)
 * 1+ 0 1+ = new ss (1)
 * 1+ 1+ 0 = in flight (2)
 *
 * Input: snapshot_metadata.switch_greater, snapshot_metadata.packet_greater
 * Output: snapshot_metadata.snapshot_on (see below)
 **/
table tiSetSnapshotCaseRollover {
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
