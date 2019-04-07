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
 * Tables and actions for the base egress pipeline of Speedlight.
 **/


// STAGE DOESNT MATTER (only used in one branch)
register reg_counter_egress {
    width : COUNTER_WIDTH;
    instance_count : PORTS_TBL_SIZE;
}

// STAGE DOESNT MATTER (only used in one branch)
register reg_last_seen_in_egress {
    width : SNAPSHOT_ID_WIDTH;
    instance_count : NEIGHBORS_TBL_SIZE_EGR;
}

// STAGE 5 ONLY
register reg_snapshot_id_egress {
    width : SNAPSHOT_ID_WIDTH;
    instance_count : PORTS_TBL_SIZE;
}

// STAGE DOESNT MATTER (only used in one branch)
register reg_snapshot_value_egress {
    width : COUNTER_WIDTH;
    instance_count: SSTABLE_SIZE;
}


/*==============================================================================
= Format for CPU                                                               =
= Strips the necessary headers and adds the notification header.  Runs when    =
= the egress port is CPU_PORT.                                                 =
==============================================================================*/

/**
 * Load packet destined for CPU, after it is cloned.
 * Packet Format: Ethernet header | last_seen_notif
 */
table teFormatForCpu {
    actions { aeFormatForCpu; }
    default_action: aeFormatForCpu();
    size : 1;
}


/*==============================================================================
= Set Effective Port                                                           =
= Translates actual port number to a contiguous 0-indexed representation to    =
= make table indexing easier.                                                  =
==============================================================================*/

/**
 * Set effective port.  Assumes that the operator has configured this table to
 * map correctly.  Also stores a decremented IPv4 IHL value (hack to avoid
 * another stage).
 */
table teSetEffectivePort {
    reads {
        standard_metadata.egress_port : exact;
    }
    actions {
        aeSetEffectivePort;
    }
    size : NUM_PORTS;
}

action aeSetEffectivePort(portIndex){
    subtract(snapshot_metadata.temp_ihl, ipv4.ihl, 2);
    modify_field(snapshot_metadata.effective_port, portIndex);
}


/*==============================================================================
= Set Snapshot Case                                                            =
= Sets snapshot_case based on the current snapshot ID and the packet's ID.     =
= Similar to ingress pipeline.  This does not take rollover into account.      =
==============================================================================*/

control ceSetSnapshotCase {
    /*
     * former_id = reg_snapshot_id_egress[effective_port]
     * if (snapshot_header.snapshot_id > former_id)
     *     reg_snapshot_id_egress[effective_port] = snapshot_header.snapshot_id
     */
    apply(teUpdateSnapshotId);
    /*
     * switch_greater = former_id - snapshot_header.snapshot_id
     * packet_greater = snapshot_header.snapshot_id - former_id
     */
    apply(teCheckSnapshotCase);
    /*
     * if (switch_greater == 0 and packet_greater == 0)
     *     snapshot_case = 0
     * else if (switch_greater == 0)
     *     snapshot_case = 1
     * else if (packet_greater == 0)
     *     snapshot_case = 2
     */
    apply(teSetSnapshotCase);
}

/**
 * Loads and possibly updates our current snapshot ID.  This should only update
 * if the packet's snapshot ID is larger than our snapshot ID.
 *
 * Input: snapshot_metadata.effective_port
 * Output: metadata.former_id = reg_snapshot_id_egress[snapshot_metadata.effective_port]
 **/
table teUpdateSnapshotId {
    actions { aeUpdateSnapshotId; }
    default_action: aeUpdateSnapshotId();
    size : 0;
}

action aeUpdateSnapshotId() {
    reUpdateSnapshotId(reg_snapshot_id_egress, snapshot_metadata.effective_port);
}

/**
 * See tiCheckSnapshotCase
 **/
table teCheckSnapshotCase {
    actions { aCheckSnapshotCase; }
    default_action: aCheckSnapshotCase();
    size : 0;
}

/**
 * See tiSetSnapshotCaseNoRollover
 **/
table teSetSnapshotCase {
    reads {
        snapshot_metadata.switch_greater : ternary;
        snapshot_metadata.packet_greater : ternary;
    }
    actions {
        aSetSnapshotCase;
    }
    size : 8;
}


/*==============================================================================
= Take Snapshot                                                                =
= Similar to ingress.  Takes a snapshot if snapshot_case == 1. This check is   =
= performed in the match tables and extern functions to minimize branches.     =
= Note that the snapshot does not include channel state.                       =
==============================================================================*/

control ceTakeSnapshot {
    /*
     * if (snapshot_case == 1)
     *     reg_snapshot_value_egress[index] = current_reading
     *     current_id = snapshot_header.snapshot_id
     */
    apply(teTakeSnapshot);
    /*
     * if (snapshot_case == 1)
     *     Notification: effective_port, snapshot_header.snapshot_id,
     *                   current_reading, ingress_global_tstamp
     */
    apply(teSendNotification);
}

/**
 * Stores counter (pre-increment) into the snapshot register
 *
 * Input:  current_index, current_reading
 * Postcondition: reg_snapshot_value_egress[current_index] = current_reading
 */
table teTakeSnapshot {
    reads {
        snapshot_metadata.snapshot_case : exact;
        snapshot_header.snapshot_id : exact;
        snapshot_metadata.effective_port : exact;
    }
    actions {
        aeTakeSnapshot;
    }
    size : DOUBLE_SSTABLE_SIZE;
}

action aeTakeSnapshot(index_val) {
    register_write(reg_snapshot_value_egress, index_val, snapshot_metadata.current_reading);
    modify_field(snapshot_metadata.current_id, snapshot_header.snapshot_id);
}

/**
 * Sends a notification to the CPU when a neighbor sends you a new snapshot ID.
 * In the traditional algorithm, we send a notification any time we get a new
 * snapshot from a neighbor.  That's essentially what we're doing here.
 *
 * This should be after the register state is consistent
 *
 * if snapshot_case == 1:
 *     CPU_NEWSS_EGRESS
 * else
 *     aNoOp
 *
 * Input: snapshot_changed_check, snapshot_feature, snapshot_case
 * Postcondition: Notification has been sent to the CPU
 **/
table teSendNotification {
    reads {
        snapshot_metadata.snapshot_case : exact;
    }
    actions {
        aeSendNotification; // in notify(_C).p4
    }
    default_action: aNoOp();
    size : 2;
}


/*==============================================================================
= Finalize Packet                                                              =
= Modify the header or drop to complete egress processing.                     =
==============================================================================*/

/**
 * Either strips the snapshot header and IPv4 Option from the packet, forwards
 * it, or drops it.
 *
 * if (ipv4_option.option == IPV4_OPTION_SS_CPU) {
 *     aeDropPacket();
 * } else if (standard_metadata.egress_port is host-facing) {
 *     aeRemoveSnapshotHeader();
 * } else {
 *     aeUpdateSnapshotHeader();
 * }
 */
table teFinalizePacket {
    reads {
        ipv4_option.option : exact;
        standard_metadata.egress_port : ternary;
    }
    actions {
        aeDropPacket;
        aeRemoveSnapshotHeader;
        aeUpdateSnapshotHeader;
    }
    default_action: aeUpdateSnapshotHeader();
    size : NUM_PORTS;
}

action aeDropPacket() {
    drop();
}

action aeRemoveSnapshotHeader() {
    remove_header(snapshot_header);
    remove_header(ipv4_option);
    modify_field(ipv4.ihl, snapshot_metadata.temp_ihl);
    subtract_from_field(ipv4.totalLen, 8);

    modify_field(ipv4_option.copyFlag, 0);
    modify_field(ipv4_option.optClass, 0);
    modify_field(ipv4_option.option, 0);
    modify_field(ipv4_option.optionLength, 0);
    modify_field(snapshot_header.snapshot_id, 0);
    modify_field(snapshot_header.port_id, 0);

    subtract_from_field(ipv4.ttl, 1);
}

action aeUpdateSnapshotHeader() {
    modify_field(snapshot_header.snapshot_id, snapshot_metadata.current_id);
    modify_field(snapshot_header.port_id, snapshot_metadata.effective_port);

    subtract_from_field(ipv4.ttl, 1);
}
