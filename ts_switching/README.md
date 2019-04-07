ts_switching_P4
=====================

Scheduled switching of media flows based on RTP timestamp in P4

Tested on bmv2 with target simple_switch

commands_ts_switching.txt: CLI commands to set up a simple schedule.

The schedule is to take input IP DST 239.1.1.1 with RTP timestamps
from 0 to 2 and emit them on IP DST 239.3.3.3, then to take input
239.2.2.2 with RTP timestamps from 3 to 4 and emit them on the
239.3.3.3, and finally to take input 239.1.1.1
again with RTP timestamps 5 to 0xF and emit them on the
239.3.3.3.
