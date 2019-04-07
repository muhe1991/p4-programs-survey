#1M packets
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv PerThreshold SampleAndHold > ../Analysis/Caida/Caida1MSampleAndHoldSummary.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Basic > ../Analysis/Caida/Caida1MBaselineSummary.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Single > ../Analysis/Caida/Caida1MSingleSummary.csv

#23M packets
java LossyFlowIdentifier ../Analysis/Caida/Caida23Mpackets.csv ../Analysis/Caida/Caida23MSizeBySrcIp.csv PerThreshold SampleAndHold > ../Analysis/Caida/Caida23MSampleAndHoldSummary.csv
java LossyFlowIdentifier ../Analysis/Caida/Caida23Mpackets.csv ../Analysis/Caida/Caida23MSizeBySrcIp.csv runTrial Basic > ../Analysis/Caida/Caida23MBaselineSummaryWithMinVal.csv
java LossyFlowIdentifier ../Analysis/Caida/Caida23Mpackets.csv ../Analysis/Caida/Caida23MSizeBySrcIp.csv runTrial Single > ../Analysis/Caida/Caida23MSingleSummary.csv




