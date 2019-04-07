#!/usr/bin/env sh

java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Basic > ../Analysis/Caida/Caida1BaselineSummaryHigh.csv

java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial coalesce > ../Analysis/Caida/Caida1CoalesceSummaryHigh.csv

java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Multi > ../Analysis/Caida/Caida1MultiLookUpSummaryHigh.csv

java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Single > ../Analysis/Caida/Caida1SingleLookUpSummaryHigh.csv



