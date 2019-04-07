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
 * Tables and actions for the base ingress pipeline of Speedlight.
 **/


// STAGE DOESNT MATTER (only used in one branch)
register reg_counter_ingress {
    width : COUNTER_WIDTH;
    instance_count : PORTS_TBL_SIZE;
}

// STAGE DOESNT MATTER (only used in one branch)
register reg_last_seen_in_ingress {
    width : SNAPSHOT_ID_WIDTH;
    instance_count : NEIGHBORS_TBL_SIZE_ING;
}

// STAGE 5 ONLY
register reg_snapshot_id_ingress {
    width : SNAPSHOT_ID_WIDTH;
    instance_count : PORTS_TBL_SIZE;
}

// STAGE DOESNT MATTER (only used in one branch)
register reg_snapshot_value_ingress {
    width : COUNTER_WIDTH;
    instance_count: SSTABLE_SIZE;
}

action aNoOp() {}


/*==============================================================================
= SS Initialization                                                            =
= Always runs and sets up effective_port and snapshot_feature                  =
==============================================================================*/

control ciInitializeSS {
    if (valid(ipv4_option)){
        apply(tiCheckOption);
    }
    /*
     * if (snapshot_feature == 2) {
     *   effective_port = snapshot_header.port_id
     * } else {
     *   effective_port = lookup(ingress_port)
     * }
     */
    apply(tiSetEffectivePort);
}

/*
 * Checks if the packet has a snapshot header and/or is a control plane snapshot
 * initiation message.  Only packets from hosts should be missing the header.
 *
 * Input: ipv4_option.option
 * Output: if option == 31, snapshot_feature = 1
 *         if option == 30, snapshot_feature = 2
 *         otherwise, snapshot_feature = 0
 */
table tiCheckOption {
    reads {
        ipv4_option.option : exact;
    }
    actions {
        aiCheckOption;
    }
    max_size : 2;
}

action aiCheckOption(feature_val) {
    modify_field(snapshot_metadata.snapshot_feature, feature_val);
}

/*
 * Sets the effective port.
 *
 * -If the ingress port is from the CPU, we fake the effective port to be the
 * snapshot header's port_id.
 * -Otherwise, we look up the ingress port in a table that compresses the ids to
 * start at 0.
 *
 * Input: ingress_port, snapshot_header.port_id
 * Output: effective_port
 */
table tiSetEffectivePort {
    reads {
        snapshot_metadata.snapshot_feature : exact;
        standard_metadata.ingress_port : ternary;
    }
    actions {
        aiSetEffectivePort;
        aiFakeEffectivePort;
    }
    size : TWO_X_PORTS_PLUS_CPU;
}

action aiSetEffectivePort(portIndex){
    modify_field(snapshot_metadata.effective_port, portIndex);
}

action aiFakeEffectivePort() {
    modify_field(snapshot_metadata.effective_port, snapshot_header.port_id);
}


/*==============================================================================
= Add SS Header                                                                =
= Runs when the packet does not have an SS header, i.e., snapshot_feature == 0 =
==============================================================================*/

control ciAddHeader {
	/*
     * current_id = reg_snapshot_id_ingress[effective_port]
     */
    apply(tiGetSnapshotId); // STAGE 5
    /*
     * packet.addIpv4Option()
     * // => [Copy = 1, Class = 2, Number = 31, Length = 8]
     * packet.addSnapshotHeader()
     * // => [ID = TBD, port_id = TBD]
     * packet.IPv4.IHL += 2
     * packet.IPv4.totalLen += 8
     */
    apply(tiAddHeader);
}

/**
 * STAGE 5
 * Loads the port's snapshot ID from a register.
 *
 * Input: snapshot_metadata.effective_port
 * Output: metadata.current_id = reg_snapshot_id_ingress[effective_port]
 **/
@pragma stage 5
table tiGetSnapshotId {
    actions { aiGetSnapshotId; }
    default_action: aiGetSnapshotId();
    size : 0;
}

action aiGetSnapshotId() {
    register_read(snapshot_metadata.current_id, reg_snapshot_id_ingress,
                  snapshot_metadata.effective_port);
}

/**
 * Adds the snapshot header to the packet.  Requires adding the IP option and
 * inserting the snapshot header after the IP header.
 * Note: snapshot_header values will be set at the end
 *
 * Preconditions:
 *     Packet does not have snapshot header
 * Postconditions:
 *     IPv4 IHL +2 and Total length +8
 *     IPv4 header option [Copy = 1, Class = 2, Number = 31, Length = 8]
 *     Snapshot header    [ID = TBD, port_id = TBD, in = TBD]
 **/
table tiAddHeader {
    actions { aiAddHeader; }
    default_action: aiAddHeader();
    size : 0;
}

action aiAddHeader() {
    add_header(ipv4_option);
    modify_field(ipv4_option.copyFlag, 1);
    modify_field(ipv4_option.option, 31);
    modify_field(ipv4_option.optionLength, 8);
    modify_field(ipv4_option.optClass, 2);

    add_to_field(ipv4.totalLen, 8);
    add_to_field(ipv4.ihl, 2);

    add_header(snapshot_header);
}


/*==============================================================================
= Set Snapshot Case                                                            =
= Sets snapshot_case based on the current snapshot ID and the packet's ID.     =
= Only runs when the packet has a snapshot header. This does not take rollover =
= into account.                                                                =
==============================================================================*/

control ciSetSnapshotCase {
    /*
     * former_id = reg_snapshot_id_ingress[effective_port]
     * if (snapshot_header.snapshot_id > former_id)
     *     reg_snapshot_id_ingress[effective_port] = snapshot_header.snapshot_id
     */
    apply(tiUpdateSnapshotId); // stage 5
    /*
     * switch_greater = former_id - snapshot_header.snapshot_id
     * packet_greater = snapshot_header.snapshot_id - former_id
     */
    apply(tiCheckSnapshotCase);
    /*
     * if (switch_greater == 0 and packet_greater == 0)
     *     snapshot_case = 0
     * else if (switch_greater == 0)
     *     snapshot_case = 1
     * else if (packet_greater == 0)
     *     snapshot_case = 2
     */
    apply(tiSetSnapshotCase);
}

/**
 * STAGE 5
 * Loads and possibly updates our current snapshot ID.  This should only update
 * if the packet's snapshot ID is further than our snapshot ID.
 *
 * former_id = reg_snapshot_id_ingress[effective_port]
 * if (snapshot_header.snapshot_id > former_id)
 *     reg_snapshot_id_ingress[effective_port] = snapshot_header.snapshot_id
 *
 * Input: effective_port, snapshot_header.snapshot_id
 * Output: former_id = reg_snapshot_id_ingress[effective_port]
 * Postcondition: reg_snapshot_id_ingress[effective_port] =
 *                        max(snapshot_header.snapshot_id,
 *                        reg_snapshot_id_ingress[effective_port])
 **/
@pragma stage 5
table tiUpdateSnapshotId {
    actions { aiUpdateSnapshotId; }
    default_action: aiUpdateSnapshotId();
    size : 0;
}

action aiUpdateSnapshotId() {
    // signature of all custom functions: <registerName, index>
    // all other metadata fields are loaded internally.
    riUpdateSnapshotId(reg_snapshot_id_ingress,
                       snapshot_metadata.effective_port);
}

/**
 * Compare switch and packet.  Subtraction is saturating.  At most one should be
 * non-zero.
 *
 * Input: former_last_seen, former_id, snapshot_id
 * Output: switch_greater, packet_greater
 **/
table tiCheckSnapshotCase {
    actions { aCheckSnapshotCase; }
    default_action: aCheckSnapshotCase();
    size : 0;
}

action aCheckSnapshotCase() {
    subtract(snapshot_metadata.switch_greater,
             snapshot_metadata.former_id, snapshot_header.snapshot_id);
    subtract(snapshot_metadata.packet_greater,
             snapshot_header.snapshot_id, snapshot_metadata.former_id);
    modify_field(snapshot_metadata.current_id, snapshot_metadata.former_id);
}

/**
 * Based on the difference between the node's snapshot ID and the packets
 * snapshot ID, decide what to do.  We will never see 1+ 1+ because it's
 * saturating.
 *
 * 0 0 = forward (0)
 * 0 1+ = new ss (1)
 * 1+ 0 = in flight (2)
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
 * Output: snapshot_metadata.snapshot_case (see below)
 **/
table tiSetSnapshotCase {
    reads {
        snapshot_metadata.switch_greater : ternary;
        snapshot_metadata.packet_greater : ternary;
    }
    actions {
        aSetSnapshotCase;
    }
    size : 8;
}

action aSetSnapshotCase(x) {
    modify_field(snapshot_metadata.snapshot_case, x);
}


/*==============================================================================
= Take Snapshot                                                                =
= Takes a snapshot if snapshot_case == 1. This check is performed in the match =
= tables and extern functions to minimize branches.  Note that the snapshot    =
= does not include channel state.                                              =
==============================================================================*/

control ciTakeSnapshot {
    /*
     * if (snapshot_case == 1)
     *     reg_snapshot_value_ingress[index] = current_reading
     *     current_id = snapshot_header.snapshot_id
     */
    apply(tiTakeSnapshot);
    /*
     * if (snapshot_case == 1)
     *     Notification: effective_port, snapshot_header.snapshot_id,
     *                   current_reading, ingress_global_tstamp
     */
    apply(tiSendNotification);
}

/**
 * Stores counter (pre-increment) into the snapshot register
 * Only executed if snapshot_case == 1
 * Input: effective_port, snapshot_id, current_reading
 * Postcondition: reg_snapshot_value_ingress[current_index] = current_reading
 */
table tiTakeSnapshot {
    reads {
        snapshot_metadata.snapshot_case : exact;
        snapshot_header.snapshot_id : exact;
        snapshot_metadata.effective_port : exact;
    }
    actions {
        aiTakeSnapshot;
    }
    size : DOUBLE_SSTABLE_SIZE;
}

action aiTakeSnapshot(index_val) {
    register_write(reg_snapshot_value_ingress, index_val,
                   snapshot_metadata.current_reading);
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
 *     CPU_NEWSS_INGRESS
 * else
 *     aNoOp
 *
 * Input: snapshot_changed_check, snapshot_feature, snapshot_case
 * Postcondition: Notification has been sent to the CPU
 **/
table tiSendNotification {
    reads {
        snapshot_metadata.snapshot_case : exact;
    }
    actions {
        aiSendNotification; // in notify(_C).p4
        aNoOp;
    }
    default_action: aNoOp();
    size : 2;
}


/*==============================================================================
= Forward CPU Initiation                                                       =
= Runs when the packet is a initiation from the CPU.  If so, forward it        =
= without modification to the egress processing unit of the same port.         =
==============================================================================*/

/**
 * Just forward the raw packet to this port's egress port.  Don't update the
 * snapshot ID or port id
 */
table tiForwardInitiation {
    reads {
        snapshot_metadata.effective_port : exact;
    }
    actions {
        aiForwardInitiation;
    }
    size : NUM_PORTS;
}

action aiForwardInitiation(port) {
    modify_field(standard_metadata.egress_spec, port);
}


/*==============================================================================
= Update Snapshot Header                                                       =
= If the packet is NOT an initiation from the CPU, i.e., a normal packet, we   =
= need to update the snapshot header.                                          =
==============================================================================*/

/**
 * Update the packet's snapshot header.
 * The snapshot header
 *
 * Input: egress_port, ingress_port, current_id
 * Postcondition: snapshot header = [snapshot_id: current_id,
 *                                   port_id: ingress_port]
 */
table tiSetSnapHeader {
    actions { aiSetSnapInfo; }
    default_action: aiSetSnapInfo();
    size : 0;
}

action aiSetSnapInfo() {
    modify_field(snapshot_header.snapshot_id, snapshot_metadata.current_id);
    modify_field(snapshot_header.port_id, snapshot_metadata.effective_port);
}
