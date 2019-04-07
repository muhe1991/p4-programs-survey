from nc_config import *
from exe_cmd import *

def failover(parameters, fail_switch_id, chains):
    fail_ip = IP_PREFIX + str(fail_switch_id + 1)
    fail_sw_port = THRIFT_PORT_OF_SWITCH[fail_switch_id]
    for i in chains:
        chain = chains[i]
        pos = chain.index(fail_ip)
        if (pos == 0):   ## if the failed switch is a head switch in the chain, get a new head
            newhead_ip = chain[pos + 1]
            newhead_sw_id = int(newhead_ip.strip().split('.')[3]) - 1
            newhead_sw_port = THRIFT_PORT_OF_SWITCH[newhead_sw_id]

            table_dump_getAddress_cmd = "table_dump get_my_address"
            extra_process_cmd_1 = " | grep 'Action entry' | awk -F ['-']+ '{print $2}'"
            action_pm = send_cmd_to_port(parameters, table_dump_getAddress_cmd, fail_sw_port, extra_process_cmd_1)

            extra_process_cmd_2 = " | grep 'Dumping entry' | awk -F [' ']+ '{print $3}'"
            table_entry = send_cmd_to_port(parameters, table_dump_getAddress_cmd, fail_sw_port, extra_process_cmd_2)

            extra_process_cmd_3 = " | grep 'nc_hdr' | awk -F [' ']+ '{print $5}'"
            match_key = send_cmd_to_port(parameters, table_dump_getAddress_cmd, fail_sw_port, extra_process_cmd_3)

            for j in range(len(match_key)):
                if match_key[j] in ENTRY[i]:

                    table_modify_getAddress_cmd = "table_modify get_my_address get_my_address_act " + str(int(table_entry[j].strip, 16)) + " " + newhead_ip + " " + str(HEAD_NODE)
                    extra_process_cmd = ""
                    send_cmd_to_port(parameters, table_modify_getAddress_cmd, newhead_sw_port, extra_process_cmd)
        elif (pos == len(chain) - 1): ## if the failed switch is a tail switch in the chain
            neighbor_ip = chain[pos - 1]
            neighbor_sw_id = int(neighbor_ip.strip().split('.')[3]) - 1
            neighbor_sw_port = THRIFT_PORT_OF_SWITCH[neighbor_sw_id]

            table_add_failover_cmd = "table_add failure_recovery failover_write_reply_act %s&&&255.255.255.255 0.0.0.0&&&0.0.0.0 0&&&0 => 3" % fail_ip
            extra_process_cmd = ""
            send_cmd_to_port_noreply(parameters, table_add_failover_cmd, neighbor_sw_port)
        else: ## if the failed switch is a middle switch in the chain
            neighbor_ip = chain[pos - 1]
            neighbor_sw_id = int(neighbor_ip.strip().split('.')[3]) - 1
            neighbor_sw_port = THRIFT_PORT_OF_SWITCH[neighbor_sw_id]

            table_add_failover_cmd = "table_add failure_recovery failover_act %s&&&255.255.255.255 0.0.0.0&&&0.0.0.0 0&&&0 => 3" % fail_ip
            extra_process_cmd = ""
            send_cmd_to_port_noreply(parameters, table_add_failover_cmd, neighbor_sw_port)
    
    return

def disable_read_write(parameters, neighbor_sw_port, fail_ip, v_group_id):
    table_add_failrecovery_cmd = "table_add failure_recovery drop_packet_act %s&&&255.255.255.255 0.0.0.0&&&0.0.0.0 %d&&&255 => 2" % (fail_ip, v_group_id)
    extra_process_cmd = ""
    send_cmd_to_port_noreply(parameters, table_add_failrecovery_cmd, neighbor_sw_port)
    return


def enable_read_write(parameters, neighbor_sw_port, fail_ip, backup_ip, v_group_id):

    table_add_failrecovery_cmd = "table_add failure_recovery failure_recovery_act %s&&&255.255.255.255 0.0.0.0&&&0.0.0.0 %d&&&255 => %s 1" % (fail_ip, v_group_id, backup_ip)
    extra_process_cmd = ""
    send_cmd_to_port_noreply(parameters, table_add_failrecovery_cmd, neighbor_sw_port)
    return

def failure_recovery(parameters, fail_switch_id, chains):
    fail_ip = IP_PREFIX + str(fail_switch_id + 1)
    backup_sw_id = BACKUP_SW_ID
    backup_ip = IP_PREFIX + str(backup_sw_id + 1)
    backup_sw_port = THRIFT_PORT_OF_SWITCH[backup_sw_id]

    vgroup = [[] for v_group_id in range(parameters.size_vgroup)]
    s_key = 2018
    for v_group_id in range(parameters.size_vgroup):
        count_key = 0
        while count_key<parameters.num_kv/parameters.size_vgroup:
            vgroup[v_group_id].append(s_key)
            count_key = count_key + 1
            s_key = s_key + 1

    for i in chains:
        chain = chains[i]
        pos = chain.index(fail_ip)
        if (pos == 0):
            role = HEAD_NODE
            target_ip = chain[pos + 1]
            neighbor_ip = chain[pos + 1]
        elif (pos == len(chain) - 1):
            role = TAIL_NODE
            target_ip = chain[pos - 1]
            neighbor_ip = chain[pos - 1]
        else:
            role = REPLICA_NODE
            target_ip = chain[pos + 1]
            neighbor_ip = chain[pos - 1]
        
        target_sw_id = int(target_ip.strip().split('.')[3]) - 1
        target_sw_port = THRIFT_PORT_OF_SWITCH[target_sw_id]

        neighbor_sw_id = int(neighbor_ip.strip().split('.')[3]) - 1
        neighbor_sw_port = THRIFT_PORT_OF_SWITCH[neighbor_sw_id]

        table_dump_getAddress_cmd = "table_dump get_my_address"
        extra_process_cmd = " | grep 'nc_hdr' | awk -F [' ']+ '{print $5}'"
        match_key_getAddress = send_cmd_to_port(parameters, table_dump_getAddress_cmd, target_sw_port, extra_process_cmd).readlines()

        table_dump_findindex_cmd = "table_dump find_index"
        extra_process_cmd_1 = " | grep 'nc_hdr' | awk -F [' ']+ '{print $5}'"
        match_key_findindex = send_cmd_to_port(parameters, table_dump_findindex_cmd, target_sw_port, extra_process_cmd_1).readlines()

        extra_process_cmd_2 = " | grep 'Action entry' | awk -F ['-']+ '{print $2}'"
        action_pm_findindex = send_cmd_to_port(parameters, table_dump_findindex_cmd, target_sw_port, extra_process_cmd_2).readlines()


        for v_group_id in range(parameters.size_vgroup):
            disable_read_write(parameters, neighbor_sw_port, fail_ip, v_group_id)

            ## copy state
            # copy table get_my_address
            vgroup_cmd = ""
            for j in range(len(match_key_getAddress)):
                match_key_j = int(match_key_getAddress[j].strip('\n'), 16)
                if (match_key_j in ENTRY[i]) and (match_key_j in vgroup[v_group_id]):
                    table_add_getAddress_cmd = "table_add get_my_address get_my_address_act " + str(match_key_j) + " => " + backup_ip + " " + str(role)
                    vgroup_cmd = vgroup_cmd + table_add_getAddress_cmd + "\n"
                    

            # copy table find_index
            tmp_index_group = []
            for j in range(len(match_key_findindex)):
                match_key_j = int(match_key_findindex[j], 16)
                action_j = int(action_pm_findindex[j], 16)

                if (match_key_j in vgroup[v_group_id]):
                    tmp_index_group.append(action_j)
                    table_add_findindex_cmd = "table_add find_index find_index_act " + str(match_key_j) + " => " + str(action_j)
                    vgroup_cmd = vgroup_cmd + table_add_findindex_cmd + "\n"
            # copy sequence register
            for j in tmp_index_group:
                register_read_sequence_cmd = "register_read sequence_reg " + str(j)
                extra_process_cmd = " | grep 'sequence_reg' | awk -F [' ']+ '{print $3}'"
                register_sequence = send_cmd_to_port(parameters, register_read_sequence_cmd, target_sw_port, extra_process_cmd).readlines()
                if (register_sequence):
                    register_write_sequence_cmd = "register_write sequence_reg " + str(j) + " " + register_sequence[0].strip('\n')
                    vgroup_cmd = vgroup_cmd + register_write_sequence_cmd + "\n"
            #copy value register
            for j in tmp_index_group:
                register_read_value_cmd = "register_read value_reg " + str(j)
                extra_process_cmd = " | grep 'value_reg' | awk -F [' ']+ '{print $3}'"
                register_value = send_cmd_to_port(parameters, register_read_value_cmd, target_sw_port, extra_process_cmd).readlines()
                if (register_value):
                    register_write_value_cmd = "register_write value_reg " + str(j) + " " + register_value[0].strip('\n')
                    vgroup_cmd = vgroup_cmd + register_write_value_cmd + "\n"
            send_cmd_to_port_noreply(parameters, vgroup_cmd, backup_sw_port)
            enable_read_write(parameters, neighbor_sw_port, fail_ip, backup_ip, v_group_id)
    return
