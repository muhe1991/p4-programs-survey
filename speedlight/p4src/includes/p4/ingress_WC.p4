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
 * Tables and actions for the channel state functions of the ingress pipeline of
 * Speedlight.
 **/


#include "ingress_W.p4"


/*==============================================================================
= Take Snapshot                                                                =
= Takes a snapshot if snapshot_case == 1 or 2. This check is performed in the  =
= match tables and extern functions to minimize branches.                      =
==============================================================================*/

control ciTakeSnapshotWithChannelState {
    /*
     * if (snapshot_case == 1)
     *     reg_snapshot_value_ingress[index] = current_reading
     *     current_id = snapshot_header.snapshot_id
     * else if (snapshot_case == 2)
     *     reg_snapshot_value_ingress[index]++
     *     current_id = former_id
     */
    apply(tiUpdateSnapshotValue);
    /*
     * Notification: effective_port, snapshot_header.snapshot_id,
     *               snapshot_metadata.current_reading, ingress_global_tstamp
     */
    apply(tiSendNotificationWithChannelState);
}

/**
 * Increments snapshot counter to account for the in-flight packet.
 * only run if snapshot_case == 2 and snapshot_feature != 2
 * second condition is taken care in the control block
 *
 * 1 _ x _ y: aiTakeSnapshot(x * MAX_PORT_NUM + y - 1)
 * 2 2 _ _ _: aNoOp
 * 2 _ _ x y: aiUpdateInflight(x * MAX_PORT_NUM + y - 1)
 *
 * Input: current_index
 * Postcondition: [case==1] reg_snapshot_value_ingress[index] = current_reading
 *                [case==2] reg_snapshot_value_ingress[index]++
 */
table tiUpdateSnapshotValue {
    reads {
        snapshot_metadata.snapshot_case: exact;
        snapshot_metadata.snapshot_feature: ternary;
        snapshot_header.snapshot_id: ternary;
        snapshot_metadata.former_id: ternary;
        snapshot_metadata.effective_port : ternary;
    }
    actions {
        aiTakeSnapshot;
        aiUpdateInflight;
        aNoOp;
    }
    size : DOUBLE_SSTABLE_SIZE;
}

/**
 * Sends a notification to the CPU when a neighbor sends you a new snapshot ID.
 * In the traditional algorithm, we send a notification any time we get a new
 * snapshot from a neighbor.  That's essentially what we're doing here.
 *
 * This should be after the register state is consistent
 *
 * if snapshot_changed_check == 0
 *     aNoOp
 * elif snapshot_case == 1 && snapshot_feature == 1:
 *     CPU_NEWSS_NEWNBR_INGRESS
 * elif snapshot_case == 1:
 *     CPU_NEWSS_INGRESS
 * elif snapshot_feature == 1:
 *     CPU_NEWNBR_INGRESS
 * else (snapshot_changed_check == 1 && snapshot_feature == 2)
 *     aNoOp
 *
 * Input: snapshot_changed_check, snapshot_feature, snapshot_case
 * Postcondition: Notification has been sent to the CPU
 **/
table tiSendNotificationWithChannelState {
    reads {
        snapshot_metadata.snapshot_changed_check : ternary;
        snapshot_metadata.snapshot_feature : ternary;
        snapshot_metadata.snapshot_case : ternary;
    }
    actions {
        aNoOp;
        aiSendNotification;
    }
    size : 8;
}
