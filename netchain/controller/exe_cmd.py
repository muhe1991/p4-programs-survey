import subprocess, os

def exe_cmd(cmd):
    subprocess.call(cmd, shell=True)
    return

def send_cmd_to_port(parameters, cmd_to_send, dst_port, extra_cmd, interprete = False):
    file_to_send = "tmp_send_cmd.txt"
    fout = open(file_to_send, "w")
    fout.write(cmd_to_send)
    fout.close()

    st = "%s --thrift-port " % parameters.runtime_CLI + str(dst_port) + " < tmp_send_cmd.txt" + extra_cmd
    return_value = os.popen(st)
    return return_value

def send_cmd_to_port_noreply(parameters, cmd_to_send, dst_port):
    file_to_send = "tmp_send_cmd_noreply.txt"
    fout = open(file_to_send, "w")
    fout.write(cmd_to_send)
    fout.close()
    
    cmd = [parameters.runtime_CLI, parameters.switch_json, str(dst_port)]
    with open(file_to_send, "r") as f:
        try:
            output = subprocess.check_output(cmd, stdin = f)
        except subprocess.CalledProcessError as e:
            print e
            print e.output