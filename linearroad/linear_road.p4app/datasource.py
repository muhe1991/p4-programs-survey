import sys
from linear_road import *

class LRDataSource:

    def __init__(self, filename=None, fd=None):
        if fd:
            self.filename = None
            self.fd = fd
        else:
            self.filename = filename

    def open(self):
        if self.filename:
            self.fd = open(self.filename, 'r')

    def close(self):
        self.fd.close()

    def next(self):
        l = next(self.fd)
        m = map(int, l.strip().split(','))
        if m[0] == LR_MSG_POS_REPORT:
            return PosReport(time=m[1],
                             vid=m[2],
                             spd=m[3],
                             xway=m[4],
                             lane=m[5],
                             dir=m[6],
                             seg=m[7])
        elif m[0] == LR_MSG_ACCNT_BAL_REQ:
            return AccntBalReq(time=m[1],
                               vid=m[2],
                               qid=m[9])
        elif m[0] == LR_MSG_EXPENDITURE_REQ:
            return ExpenditureReq(time=m[1],
                                  vid=m[2],
                                  qid=m[9],
                                  xway=m[4],
                                  day=m[14])
        elif m[0] == LR_MSG_TRAVEL_ESTIMATE_REQ:
            return TravelEstimateReq(time=m[1],
                                     qid=m[9],
                                     xway=m[4],
                                     seg_init=m[10],
                                     seg_end=m[11],
                                     dow=m[12],
                                     tod=m[13])
        else:
            raise Exception("Unsupported message type: %d" % m[0])

    def __iter__(self): return self

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, t, v, tb): self.close()


if __name__ == '__main__':
    # Example usage: follow the first vehicle
    import sys
    vid = None
    with LRDataSource(sys.argv[1]) as ds:
        for m in ds:
            if not isinstance(m, PosReport): continue
            if vid is None: vid = m['vid']
            if m['vid'] != vid: continue
            print m

