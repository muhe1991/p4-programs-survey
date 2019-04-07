#java AggregateModelVerifier ../Analysis/Caida/Caida750ThSizeBySrcIp.csv > ../Analysis/Caida/Caida750ThAggVerification.csv 2> ../Analysis/Caida/Caida750ThAggInputStream.csv
#java AggregateModelVerifier ../Analysis/Caida/Caida3MSizeBySrcIp.csv > ../Analysis/Caida/Caida3MAggVerification.csv 2> ../Analysis/Caida/Caida3MAggInputStream.csv
#java AggregateModelVerifier ../Analysis/Caida/caida5MillionSplit1SizeBySrcIp.csv > ../Analysis/Caida/Caida5MAggVerification.csv 2> ../Analysis/Caida/Caida5MAggInputStream.csv
#java AggregateModelVerifier ../Analysis/Caida/Caida23MSizeBySrcIp.csv > ../Analysis/Caida/Caida23MAggVerification.csv 2> ../Analysis/Caida/Caida23MAggInputStream.csv
java AggregateModelVerifier ../Analysis/Caida/Caida750ThSizeBySrcIp.csv 2> ../Analysis/Caida/Caida750ThAggNumCompFlowsFreq.csv
java AggregateModelVerifier ../Analysis/Caida/Caida3MSizeBySrcIp.csv 2> ../Analysis/Caida/Caida3MAggNumCompFlowsFreq.csv
java AggregateModelVerifier ../Analysis/Caida/caida5MillionSplit1SizeBySrcIp.csv 2> ../Analysis/Caida/Caida5MAggNumCompFlowsFreq.csv
java AggregateModelVerifier ../Analysis/Caida/Caida23MSizeBySrcIp.csv 2> ../Analysis/Caida/Caida23MAggNumCompFlowsFreq.csv

