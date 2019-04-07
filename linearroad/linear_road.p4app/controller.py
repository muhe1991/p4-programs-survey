import subprocess
from appcontroller import AppController
from controller_rpc import RPCServer
from linear_road import *

def stoppedIdx(xway, seg, dir, lane):
    """ Index into register of counters of stopped vehicles for each location """
    return (xway * LR_NUM_SEG * LR_NUM_DIRS * LR_NUM_LANES) + (seg * LR_NUM_DIRS * LR_NUM_LANES) + (dir * LR_NUM_LANES) + lane

def dirsegIdx(xway, seg, dir):
    """ Index into direction-segment state registers """
    return (xway * LR_NUM_SEG * LR_NUM_DIRS) + (seg * LR_NUM_DIRS) + dir

class CustomAppController(AppController):

    def __init__(self, *args, **kwargs):
        AppController.__init__(self, *args, **kwargs)
        self.rpc_server = RPCServer(self)
        self.toll_settings = dict(base_toll=2, min_spd=40, min_cars=50)

    def start(self):
        self.rpc_server.start()
        AppController.start(self)

    def getStoppedCnt(self, xway=None, seg=None, dir=None, lane=None):
        idx = stoppedIdx(xway, seg, dir, lane)
        cnt = self.readRegister('stopped_cnt_reg', idx)
        return int(cnt)

    def getVidState(self, vid=None):
        state = LRMsg(dir=0)
        for k in ['spd', 'valid', 'seg', 'xway', 'lane', 'nomove_cnt']:
            v = self.readRegister('v_%s_reg' % k, vid)
            state[k] = int(v)
        return state

    def getSegState(self, xway=None, seg=None, dir=None):
        state = {}
        for k in ['vol', 'ewma_spd']:
            v = self.readRegister('seg_%s_reg'%k, dirsegIdx(xway, seg, dir))
            state[k] = int(v)
        return state

    def getBal(self, vid=None):
        bal = int(self.readRegister('v_accnt_bal', vid))
        return bal

    def setToll(self, **kw):
        self.toll_settings.update(kw)
        commands = ['table_clear check_toll']
        commands += ['table_add check_toll issue_toll 1 0->%d %d->0xff 0 => %d 1' %
                            (self.toll_settings['min_spd'],
                             self.toll_settings['min_cars'],
                             self.toll_settings['base_toll'])]
        self.sendCommands(commands)
        return self.toll_settings

    def stop(self):
        #v_state = self.getVidState(vid=1)
        #stp_cnt = self.getStoppedCnt(**v_state.loc())
        #print v_state
        #print "stp_cnt:", stp_cnt
        self.rpc_server.stop()
        AppController.stop(self)

