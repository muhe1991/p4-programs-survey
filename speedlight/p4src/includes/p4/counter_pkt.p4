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
 * Packet counter code.
 **/


// Gets and post-increments ingress counter.
// 
// Input: effective_port
// Output: current_reading
// Postcondition: reg_counter_ingress[effective_port]++
table tiReadAndUpdateCounter {
    actions { aiReadAndUpdateCounter; }
    default_action: aiReadAndUpdateCounter();
    size : 0;
}

action aiReadAndUpdateCounter() {
    riReadAndUpdateCounter(reg_counter_ingress,
                           snapshot_metadata.effective_port);
}

action aiUpdateInflight(index_val) {
    riUpdateInflight(reg_snapshot_value_ingress, index_val);
    modify_field(snapshot_metadata.current_id, snapshot_metadata.former_id);
}

// Gets and post-increments egress counter.
// 
// Input: effective_port
// Output: current_reading
// Postcondition: reg_counter_egress[effective_port]++
table teReadAndUpdateCounter {
    actions { aeReadAndUpdateCounter; }
    default_action: aeReadAndUpdateCounter();
    size : 0;
}

action aeReadAndUpdateCounter() {
    reReadAndUpdateCounter(reg_counter_egress,
                           snapshot_metadata.effective_port);
}

action aeUpdateInflight(index_val) {
    reUpdateInflight(reg_snapshot_value_egress, index_val);
    modify_field(snapshot_metadata.current_id, snapshot_metadata.former_id);
}
