#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv noTrial Basic 1500 > ../Analysis/Caida/CaidaSplit1BaselineSize1500.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv noTrial Multi 1500 > ../Analysis/Caida/CaidaSplit1MultiLookUpSize1500.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv noTrial Single 1500 > ../Analysis/Caida/CaidaSplit1SingleLookUpSize1500.csv
java TopKIdentifier2 ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Basic > ../Analysis/Caida/Caida1MTopKBaselineSummaryWith1.csv
java TopKIdentifier2 ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Multi > ../Analysis/Caida/Caida1MTopKSingleSummary.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial Single > ../Analysis/Caida/CaidaSplit1SingleLookUpIncD.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv runTrial coalesce > ../Analysis/Caida/CaidaSplit1CoalesceSummary.csv
#java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv noTrial coalesce 1500 > ../Analysis/Caida/CaidaSplit1CoalesceSize1500.csv




