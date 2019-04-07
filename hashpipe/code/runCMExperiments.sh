#java LossyFlowIdentifier ../Analysis/Caida/Caida750Thpackets.csv ../Analysis/Caida/Caida750ThSizeBySrcIp.csv perThreshold NoKeyNoRepBit > ../Analysis/Caida/Caida750ThCMNoKeysSummary.csv
java LossyFlowIdentifier ../Analysis/Caida/Caida750Thpackets.csv ../Analysis/Caida/Caida750ThSizeBySrcIp.csv perThreshold Keys > ../Analysis/Caida/Caida750ThCMKeysSummary.csv
# java LossyFlowIdentifier ../Analysis/Caida/caidaSplit1.csv ../Analysis/Caida/caidaSplit1SizeBySrcIp.csv perThreshold NoKeyRepBit > ../Analysis/Caida/CaidaSplit1CountMinNoKeyRepBitWithThrSummary.csv
