import struct
import socket
import errno

LR_ENTRY_LANE   = 0
LR_EXIT_LANE    = 4

LR_NUM_XWAY  = 2
LR_NUM_SEG   = 100
LR_NUM_LANES = 3
LR_NUM_DIRS  = 2

LR_MSG_POS_REPORT           = 0
LR_MSG_ACCNT_BAL_REQ        = 2
LR_MSG_EXPENDITURE_REQ      = 3
LR_MSG_TRAVEL_ESTIMATE_REQ  = 4
LR_MSG_TOLL_NOTIFICATION    = 10
LR_MSG_ACCIDENT_ALERT       = 11
LR_MSG_ACCNT_BAL            = 12
LR_MSG_EXPENDITURE_REPORT   = 13
LR_MSG_TRAVEL_ESTIMATE      = 14

def locId(loc):
    return tuple(loc[k] for k in ['xway', 'seg', 'dir', 'lane'])

def Loc(*args, **kw):
    loc = {}

    assert len(args) == 0 or len(args) == 1
    if len(args) == 1:
        msg = args[0]
        for k in ['xway', 'seg', 'dir', 'lane']: loc[k] = msg[k]

    for k,v in kw.iteritems():
        if v is None:
            if k in loc: del loc[k]
        else:
            loc[k] =v
    return loc

class LRMsg(dict):
    name = 'LRMsg'
    pretty_exclude_keys = []

    def __str__(self):
        kv_strs = ["%s: %s" % (str(k), str(v)) for k,v in self.iteritems() if k not in self.pretty_exclude_keys]
        return '%s{%s}' % (self.name, ', '.join(kv_strs))

    def loc(self):
        """ Get location refered to by this message, if any. """
        return dict((k, self[k]) for k in ['xway', 'seg', 'dir', 'lane'])


class PosReport(LRMsg):
    name = 'Pos'
    pretty_exclude_keys = ['msg_type']

class AccidentAlert(LRMsg):
    name = 'Acc'
    pretty_exclude_keys = ['msg_type']

class TollNotification(LRMsg):
    name = 'Toll'
    pretty_exclude_keys = ['msg_type']

class AccntBalReq(LRMsg):
    name = 'BalReq'
    pretty_exclude_keys = ['msg_type']

class AccntBal(LRMsg):
    name = 'Bal'
    pretty_exclude_keys = ['msg_type']

class ExpenditureReq(LRMsg):
    name = 'ExpReq'
    pretty_exclude_keys = ['msg_type']

class ExpenditureReport(LRMsg):
    name = 'ExpRep'
    pretty_exclude_keys = ['msg_type']

class TravelEstimate(LRMsg):
    name = 'Est'
    pretty_exclude_keys = ['msg_type']

class TravelEstimateReq(LRMsg):
    name = 'EstReq'
    pretty_exclude_keys = ['msg_type']


msg_type_struct = struct.Struct('!B')
position_report_struct = struct.Struct('!B H L B B B B B')
toll_notification_struct = struct.Struct('!B H L H B H')
accident_alert_struct = struct.Struct('!B H L H B')
accnt_bal_req_struct = struct.Struct('!B H L L')
accnt_bal_struct = struct.Struct('!B H L H L L')
expenditure_req_struct = struct.Struct('!B H L L B B')
expenditure_report_struct = struct.Struct('!B H H L H')
travel_estimate_req_struct = struct.Struct("!B H L B B B B B")
travel_estimate_struct = struct.Struct("!B L H H")

def packPosReport(msg_type=LR_MSG_POS_REPORT, time=0, vid=0, spd=0,
                    xway=0, lane=0, dir=0, seg=0):
    assert 0 <= time and time <= 10799
    assert 0 <= spd and spd <= 100
    assert 0 <= lane and lane <= 4
    assert 0 <= dir and dir <= 1
    assert 0 <= seg and seg <= 99
    data = position_report_struct.pack(msg_type, time, vid, spd, xway, lane, dir, seg)
    return data

def unpackPosReport(data):
    msg_type, time, vid, spd, xway, lane, dir, seg = position_report_struct.unpack(data)
    assert msg_type == LR_MSG_POS_REPORT
    msg = PosReport(msg_type=msg_type, time=time, vid=vid, spd=spd,
                xway=xway, lane=lane, dir=dir, seg=seg)
    return msg

def packTollNotification(msg_type=LR_MSG_TOLL_NOTIFICATION, time=0, vid=0,
                            emit=0, spd=0, toll=0):
    data = toll_notification_struct.pack(msg_type, time, vid, emit, spd, toll)
    return data

def unpackTollNotification(data):
    msg_type, time, vid, emit, spd, toll = toll_notification_struct.unpack(data)
    assert msg_type == LR_MSG_TOLL_NOTIFICATION
    msg = TollNotification(msg_type=msg_type, time=time, vid=vid, emit=emit, spd=spd, toll=toll)
    return msg

def packAccidentAlert(msg_type=LR_MSG_ACCIDENT_ALERT, time=0, vid=0, emit=0, seg=0):
    data = accident_alert_struct.pack(msg_type, time, vid, emit, seg)
    return data

def unpackAccidentAlert(data):
    msg_type, time, vid, emit, seg = accident_alert_struct.unpack(data)
    assert msg_type == LR_MSG_ACCIDENT_ALERT
    msg = AccidentAlert(msg_type=msg_type, time=time, vid=vid, emit=emit, seg=seg)
    return msg

def packAccntBalReq(msg_type=LR_MSG_ACCNT_BAL_REQ, time=0, vid=0, qid=0):
    data = accnt_bal_req_struct.pack(msg_type, time, vid, qid)
    return data

def unpackAccntBalReq(data):
    msg_type, time, vid, qid = accnt_bal_req_struct.unpack(data)
    assert msg_type == LR_MSG_ACCNT_BAL_REQ
    msg = AccntBalReq(msg_type=msg_type, time=time, vid=vid, qid=qid)
    return msg

def packAccntBal(msg_type=LR_MSG_ACCNT_BAL, time=0, vid=0, emit=0, qid=0, bal=0):
    data = accnt_bal_struct.pack(msg_type, time, vid, emit, qid, bal)
    return data

def unpackAccntBal(data):
    print len(data), accnt_bal_struct.size
    msg_type, time, vid, emit, qid, bal = accnt_bal_struct.unpack(data)
    assert msg_type == LR_MSG_ACCNT_BAL
    msg = AccntBal(msg_type=msg_type, time=time, vid=vid, emit=emit, qid=qid, bal=bal)
    return msg

def packExpenditureReq(msg_type=LR_MSG_EXPENDITURE_REQ, time=0, vid=0, qid=0, xway=0, day=0):
    data = expenditure_req_struct.pack(msg_type, time, vid, qid, xway, day)
    return data

def unpackExpenditureReq(data):
    msg_type, time, vid, qid, xway, day = expenditure_req_struct.unpack(data)
    assert msg_type == LR_MSG_EXPENDITURE_REQ
    msg = ExpenditureReq(msg_type=msg_type, time=time, vid=vid, qid=qid, xway=xway, day=day)
    return msg

def packExpenditureReport(msg_type=LR_MSG_EXPENDITURE_REPORT, time=0, emit=0, qid=0, bal=0):
    data = expenditure_report_struct.pack(msg_type, time, emit, qid, bal)
    return data

def unpackExpenditureReport(data):
    msg_type, time, emit, qid, bal = expenditure_report_struct.unpack(data)
    assert msg_type == LR_MSG_EXPENDITURE_REPORT
    msg = ExpenditureReport(msg_type=msg_type, time=time, emit=emit, qid=qid, bal=bal)
    return msg

def packTravelEstimateReq(msg_type=LR_MSG_TRAVEL_ESTIMATE_REQ, time=0, qid=0, xway=0,
                        seg_init=0, seg_end=0, dow=0, tod=0):
    data = travel_estimate_req_struct.pack(msg_type, time, qid, xway, seg_init, seg_end, dow, tod)
    return data

def unpackTravelEstimateReq(data):
    msg_type, time, qid, xway, seg_init, seg_end, dow, tod = travel_estimate_req_struct.unpack(data)
    assert msg_type == LR_MSG_TRAVEL_ESTIMATE_REQ
    msg = TravelEstimateReq(msg_type=msg_type, time=time, qid=qid, xway=xway,
                            seg_init=seg_init, seg_end=seg_end, dow=dow, tod=tod)
    return msg

def packTravelEstimate(msg_type=LR_MSG_TRAVEL_ESTIMATE, qid=0, travel_time=0, toll=0):
    data = travel_estimate_struct.pack(msg_type, qid, travel_time, toll)
    return data

def unpackTravelEstimate(data):
    msg_type, qid, travel_time, toll = travel_estimate_struct.unpack(data)
    assert msg_type == LR_MSG_TRAVEL_ESTIMATE
    msg = TravelEstimate(msg_type=msg_type, qid=qid, travel_time=travel_time, toll=toll)
    return msg


def unpackLRMsg(data):
    msg_type, = msg_type_struct.unpack(data[0])
    if msg_type == LR_MSG_POS_REPORT:
        return unpackPosReport(data)
    elif msg_type == LR_MSG_ACCIDENT_ALERT:
        return unpackAccidentAlert(data)
    elif msg_type == LR_MSG_TOLL_NOTIFICATION:
        return unpackTollNotification(data)
    elif msg_type == LR_MSG_ACCNT_BAL_REQ:
        return unpackAccntBalReq(data)
    elif msg_type == LR_MSG_ACCNT_BAL:
        return unpackAccntBal(data)
    elif msg_type == LR_MSG_EXPENDITURE_REQ:
        return unpackExpenditureReq(data)
    elif msg_type == LR_MSG_EXPENDITURE_REPORT:
        return unpackExpenditureReport(data)
    elif msg_type == LR_MSG_TRAVEL_ESTIMATE_REQ:
        return unpackTravelEstimateReq(data)
    elif msg_type == LR_MSG_TRAVEL_ESTIMATE:
        return unpackTravelEstimate(data)
    else:
        raise Exception("Unrecognized msg type: %d" % msg_type)

def packLRMsg(msg):
    if isinstance(msg, PosReport):
        return packPosReport(**msg)
    elif isinstance(msg, AccidentAlert):
        return packAccidentAlert(**msg)
    elif isinstance(msg, TollNotification):
        return packTollNotification(**msg)
    elif isinstance(msg, AccntBalReq):
        return packAccntBalReq(**msg)
    elif isinstance(msg, AccntBal):
        return packAccntBal(**msg)
    elif isinstance(msg, ExpenditureReq):
        return packExpenditureReq(**msg)
    elif isinstance(msg, ExpenditureReport):
        return packExpenditureReport(**msg)
    elif isinstance(msg, TravelEstimateReq):
        return packTravelEstimateReq(**msg)
    elif isinstance(msg, TravelEstimate):
        return packTravelEstimate(**msg)
    else:
        raise Exception("Packing this msg type isn't supported yet")


def parseHostAndPort(host_and_port, default_port=1234):
    parts = host_and_port.split(':')
    assert len(parts) >= 1
    if len(parts) == 1:
        return (parts[0], default_port)
    else:
        return (parts[0], int(parts[1]))


class LRConsumer:

    def __init__(self, port, timeout=None):
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(('', self.port))
        self.sock.settimeout(timeout)
        self.recv_queue = []

    def recv(self):
        if len(self.recv_queue) > 0:
            data = self.recv_queue.pop()
        else:
            data, addr = self.sock.recvfrom(2048)
            if not data: return None

        msg = unpackLRMsg(data)
        return msg

    def hasNewMsg(self):
        if len(self.recv_queue) > 0: return True
        try:
            self.sock.setblocking(0)
            data, addr = self.sock.recvfrom(2048)
            self.recv_queue.insert(0, data)
            return True
        except socket.error as e:
            err = e.args[0]
            if err == errno.EAGAIN or err == errno.EWOULDBLOCK:
                return False
            raise e
        finally:
            self.sock.setblocking(1)


    def recvMany(self, count, ignoretype=None):
        msgs = []
        while len(msgs) < count:
            msg = self.recv()
            if ignoretype is not None:
                if isinstance(msg, ignoretype):
                    continue
            msgs.append(msg)

        return msgs


    def close(self):
        self.sock.close()


class LRProducer:
    def __init__(self, dst_host, dst_port):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.dst_addr = (dst_host, dst_port)

    def send(self, msg):
        data = packLRMsg(msg)
        self.sock.sendto(data, self.dst_addr)

    def close(self):
        self.sock.close()
