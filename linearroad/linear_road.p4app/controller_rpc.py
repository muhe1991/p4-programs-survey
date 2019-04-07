import socket
from threading import Thread
import json
import os

CONTROLLER_IPC_SOCK = '/tmp/lr_controller.sock'
CLIENT_IPC_SOCK_TMPL = '/tmp/lr_client_%d.sock'

RPC_CMDS = ['getStoppedCnt', 'getVidState', 'getSegState', 'setToll', 'getBal']

def serialize(o):
    return json.dumps(o)

def deserialize(data):
    o = json.loads(data)
    return dict((str(k), v) for k,v in o.iteritems())

class RPCClient:

    def __init__(self):
        self.cl_id = 1
        self.sock_path = CLIENT_IPC_SOCK_TMPL % self.cl_id
        self.__connect()

    def __connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        self.sock.bind(self.sock_path)

        if not os.path.exists(CONTROLLER_IPC_SOCK):
            raise Exception("Socket file does not exist: %s" % CONTROLLER_IPC_SOCK)
        self.controller_sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        self.controller_sock.connect(CONTROLLER_IPC_SOCK)

        self._send(dict(cmd='__connect', cl_sock=self.sock_path))

    def _send(self, msg):
        msg['cl_id'] = self.cl_id
        data = serialize(msg)
        self.controller_sock.send(data)
        resp = self.sock.recv(2048)
        return deserialize(resp)

def addCmdMethod(cmd):
    def call_cmd(self, **kwargs):
        req = dict(cmd=cmd, args=kwargs)
        resp = self._send(req)
        return resp['res']
    setattr(RPCClient, cmd, call_cmd)

for cmd in RPC_CMDS:
    addCmdMethod(cmd)


class RPCServer(Thread):

    def __init__(self, controller):
        Thread.__init__(self)
        self.controller = controller
        self.cl_socks = {}

    def run(self):
        if os.path.exists(CONTROLLER_IPC_SOCK):
          os.remove(CONTROLLER_IPC_SOCK)

        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        self.sock.bind(CONTROLLER_IPC_SOCK)

        print "Controller RPC server listening..."

        while True:
            data = self.sock.recv(2048)
            if not data: break

            req = deserialize(data)

            if req['cmd'] == '__connect':
                self.handleConnect(req)
            elif hasattr(self.controller, req['cmd']):
                self.callAndReply(req)
            else:
                self.reply(req, dict(err='unsupported cmd'))

    def handleConnect(self, req):
        self.cl_socks[req['cl_id']] = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        self.cl_socks[req['cl_id']].connect(req['cl_sock'])
        self.reply(req, {})

    def callAndReply(self, req):
        method = getattr(self.controller, req['cmd'])
        res = method(**req['args'])
        self.reply(req, dict(res=res))

    def reply(self, req, resp):
        self.cl_socks[req['cl_id']].send(serialize(resp))

    def stop(self):
        self.sock.shutdown(socket.SHUT_RDWR)
        self.sock.close()
        self.join()

