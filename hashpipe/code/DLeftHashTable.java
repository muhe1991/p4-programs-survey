import java.util.*;

/* hash table simulation to track the unique flows experiencing loss
	using the D-Left hashing procedure where each flow id is hashed exactly
	d times to generate d locations where the flow and its loss might be
	stored* */

public class DLeftHashTable{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private double problematicEvictions;
	private double totalEvictions;
	private int totalNumberOfPackets;

	private Sketch countMinSketch;
	private FlowWithCount[] buckets;
	private int[] keysBeenInIndex;
	private long[] flowIdBuckets;
	private HashSet<Long> bloomfilter;

	private SummaryStructureType type;
	private final int D;
	private HashMap<Long, Integer> actualFlowSizes;
	private HashMap<Long, Integer> flowToRank;

	public DLeftHashTable(int tableSize, SummaryStructureType type, int numberOfFlows, int D, HashMap<Long,Integer> flowSizes){
		this.tableSize = tableSize;
		this.D = D;
		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		problematicEvictions = 0;
		totalEvictions = 0;
		totalNumberOfPackets = 0;
		this.actualFlowSizes = flowSizes;

		// given input, so ideal order of heavy hitters
		ArrayList<FlowWithCount> flowSizesList = new ArrayList<FlowWithCount>();
		for (long f : flowSizes.keySet()){
			flowSizesList.add(new FlowWithCount(f, flowSizes.get(f)));
		}
		FlowWithCount[] inputFlowArray = new FlowWithCount[flowSizesList.size()];
		inputFlowArray = flowSizesList.toArray(inputFlowArray);
		Arrays.sort(inputFlowArray);

		// get the ranks of all flows and populate rank map
		flowToRank = new HashMap<Long, Integer>();
		for (int i = 0; i < inputFlowArray.length; i++){
			flowToRank.put(inputFlowArray[i].flowid, i + 1);
		}


		this.type = type;

		if (type == SummaryStructureType.DLeft || type == SummaryStructureType.BasicHeuristic || type == SummaryStructureType.MinReplacementHeuristic || type == SummaryStructureType.OverallMinReplacement){
			buckets = new FlowWithCount[tableSize];
			keysBeenInIndex = new int[tableSize];
		
			for (int j = 0; j < tableSize; j++){
				buckets[j] = new FlowWithCount(0, 0);
			}
		}
		else if (type == SummaryStructureType.EvictionWithCount){
			buckets = new FlowWithCount[tableSize];
		
			for (int j = 0; j < tableSize; j++){
				buckets[j] = new FlowWithCount(0, 0);
			}

			countMinSketch = new Sketch(tableSize/3, 3, numberOfFlows);
		}
		else if (type == SummaryStructureType.RollingMinWithBloomFilter || type == SummaryStructureType.RollingMinWihoutCoalescense || type == SummaryStructureType.RollingMinSingleLookup || type == SummaryStructureType.AsymmetricDleftSingleLookUp){
			buckets = new FlowWithCount[tableSize];

			for (int j = 0; j < tableSize; j++){
				buckets[j] = new FlowWithCount(0,0);
			}

			//bloom filter
			bloomfilter = new HashSet<Long>();
		}
		else {
			flowIdBuckets = new long[tableSize];
		
			for (int j = 0; j < tableSize; j++){
				flowIdBuckets[j] = 0;
			}

			countMinSketch = new Sketch(tableSize/3, 3, numberOfFlows);
		}
	}

	public void processData(long key, int keynum, HashMap<Integer, Integer> rankToFrequency){
		if (type == SummaryStructureType.EvictionWithoutCount)
			processDataWithoutCountInTable(key);
		else
			processDataWithCountInTable(key, keynum, rankToFrequency);
	}

	public void processDataWithoutCountInTable(long key){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 5171;
		final int hashA[] = { 	421, 	199,	83,	89,	97,	101,	103,	107,	109,	113,
								127,	131,	137,	139,	149,	151,	157,	163,	167,	173,
								179,	181,	191,	193,	197,	199,	211,	223,	227,	229,
								233,	239,	241,	251,	257,	263,	269,	271,	277,	281,
								283,	293,	307,	311,	313,	317,	331,	337,	347,	349,
								353,	359,	367,	373,	379,	383,	389,	397,	401,	409,
								419,	421,	431,	433,	439,	443,	449,	457,	461,	463,
								467,	479,	487,	491,	499,	503,	509,	521,	523,	541,
								547,	557,	563,	569,	571,	577,	587,	593,	599,	601,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1229,	1231,	1237,	1249,	1259,	1277,	1279,	1283,	1289,	1291,
								1297,	1301,	1303,	1307,	1319,	1321,	1327,	1361,	1367,	1373,
								1381,	1399,	1409,	1423,	1427,	1429,	1433,	1439,	1447,	1451};

			//421, 149, 311, 701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453};
		final int hashB[] = {   73,		3079,	617,	619,	631,	641,	643,	647,	653,	659,
								661,	673,	677,	683,	691,	701,	709, 	719,	727,	733,
								739,	743,	751,	757,	761,	769,	773,	787,	797,	809,
								811,	821,	823,	827,	829,	839,	853,	857,	859, 	863,
								877,	881,	883,	887,	907,	911,	919,	929,	937,	941,
								947, 	953,	967,	971,	977,	983, 	991,	997, 	1009,	1013,
								1019,	1021,	1031,	1033,	1039,	1049,	1051,	1061,	1063,	1069,
								1087,	1091,	1093,	1097,	1103,	1109,	1117,	1123,	1129,	1151,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1453,	1459,	1471,	1481,	1483,	1487,	1489,	1493,	1499,	1511,
								1523,	1531,	1543,	1549,	1553,	1559,	1567,	1571,	1579,	1583,
								1597,	1601,	1607,	1609,	1613,	1619,	1621,	1627,	1637,	1657};

			//73, 109, 233, 31, 151, 3359, 643, 1103, 2927, 3061, 409, 3079, 2341, 179, 1213
		totalNumberOfPackets++;

		// update the count-min sketch for this flowid
		countMinSketch.updateCount(key);

		/* uniform hashing into a chunk N/d and then dependent picking of the choice*/
		int k = 0;

		// keep track of which of the d locations has the minimum lost packet count
		// use this location to place the incoming flow if there is a collision
		int minIndex = 0;
		int minValue = -1;

		for (k = 0; k < D; k++){
			int index = (int) ((hashA[k]*key + hashB[k]) % P) % (tableSize/D) + (k*tableSize/D);
								
			// this flow has been seen before
			if (flowIdBuckets[index] == key) {
				break;
			}

			// new flow
			if (flowIdBuckets[index] == 0) {
				flowIdBuckets[index] = key;
				break;
			}

			// track min - first time explicitly set the value
			if (countMinSketch.estimateCount(flowIdBuckets[index]) < minValue || k == 0){
				minValue = (int) countMinSketch.estimateCount(flowIdBuckets[index]);
				minIndex = index;
			}
		}

		// TODO: figure out if the incoming flow has a higher loss than one of the existing flows in the table
		// find a way of tracking the information of the incoming flow because it isnt the hash table
		// so we don't have information on what its loss count is nd the very first time it comes in, loss is 0
		if (k == D) {
			//System.out.println("Min Index: " + minIndex + "minValue: " + minValue + "current id: " + packets.get(j) + "existing id: " + buckets[minIndex]);
			if (countMinSketch.estimateCount(flowIdBuckets[minIndex]) < countMinSketch.estimateCount(key)){
				//packetsInfoDroppedAtFlow[packets.get(j) - 1] = 0;
				//packetsInfoDroppedAtFlow[buckets[minIndex] - 1] = (int) countMinSketch.estimateCount(buckets[minIndex]);
				droppedPacketInfoCount = droppedPacketInfoCount + (int) countMinSketch.estimateCount(flowIdBuckets[minIndex]) - (int) countMinSketch.estimateCount(key);
				flowIdBuckets[minIndex] = key;
			}
			else{
				//packetsInfoDroppedAtFlow[packets.get(j) - 1]++;
				droppedPacketInfoCount++;
			}
		}
	}

	public void processDataWithCountInTable(long key, int keynum, HashMap<Integer, Integer> rankToFrequency){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 9029;
		final int hashA[] = { 	10273, 8941, 11597, 9203, 12289, 11779,
								421, 	199, 	79,	83,	89,	97,	101,	103,	107,	109,	113,
								127,	131,	137,	139,	149,	151,	157,	163,	167,	173,
								179,	181,	191,	193,	197,	199,	211,	223,	227,	229,
								233,	239,	241,	251,	257,	263,	269,	271,	277,	281,
								283,	293,	307,	311,	313,	317,	331,	337,	347,	349,
								353,	359,	367,	373,	379,	383,	389,	397,	401,	409,
								419,	421,	431,	433,	439,	443,	449,	457,	461,	463,
								467,	479,	487,	491,	499,	503,	509,	521,	523,	541,
								547,	557,	563,	569,	571,	577,	587,	593,	599,	601,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1229,	1231,	1237,	1249,	1259,	1277,	1279,	1283,	1289,	1291,
								1297,	1301,	1303,	1307,	1319,	1321,	1327,	1361,	1367,	1373,
								1381,	1399,	1409,	1423,	1427,	1429,	1433,	1439,	1447,	1451};

			//421, 149, 311, 701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453};
		final int hashB[] = {   12037, 12289, 9677, 11447, 8837, 10847, 
			                    73, 	3079, 	613,	617,	619,	631,	641,	643,	647,	653,	659,
								661,	673,	677,	683,	691,	701,	709, 	719,	727,	733,
								739,	743,	751,	757,	761,	769,	773,	787,	797,	809,
								811,	821,	823,	827,	829,	839,	853,	857,	859, 	863,
								877,	881,	883,	887,	907,	911,	919,	929,	937,	941,
								947, 	953,	967,	971,	977,	983, 	991,	997, 	1009,	1013,
								1019,	1021,	1031,	1033,	1039,	1049,	1051,	1061,	1063,	1069,
								1087,	1091,	1093,	1097,	1103,	1109,	1117,	1123,	1129,	1151,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1453,	1459,	1471,	1481,	1483,	1487,	1489,	1493,	1499,	1511,
								1523,	1531,	1543,	1549,	1553,	1559,	1567,	1571,	1579,	1583,
								1597,	1601,	1607,	1609,	1613,	1619,	1621,	1627,	1637,	1657,
								3221, 	3229, 	3251, 	3253, 	3257,	3259, 	3271, 	3299,	3301, 	3307, 
								3313, 	3319, 	3323, 	3329, 	3331};


		totalNumberOfPackets++;

		// keep track of which of the d locations has the minimum lost packet count
		// use this location to place the incoming flow if there is a collision
		int minIndex = 0;
		long minValue = -1;
		boolean isNew = false;
		long keyBeingCarried = key;
		long valueBeingCarried = 1;

		// update the count-min sketch for this flowid if the data type is so
		if (type == SummaryStructureType.EvictionWithCount)
			countMinSketch.updateCount(key);

		// Look up the bloomfilter for whether the key is expected
		if (type == SummaryStructureType.RollingMinWithBloomFilter){
			isNew = !(bloomfilter.contains(key));
		}

		/* uniform hashing into a chunk N/d and then dependent picking of the choice*/
		int k = 0;
		int firstLocation = 0; // how to track this in hardware
		boolean notMatched = true;

		if (key == 0)
		{
			System.out.print("invalid Key");
			return;
		}

		if (type == SummaryStructureType.OverallMinReplacement){
			minIndex = 0;
			minValue = buckets[0].count;

			for (k = 0; k < buckets.length; k++){
				if (buckets[k].flowid == key){
					buckets[k].count++;
					//keysBeenInIndex[k]++;
					return;
				}

				if (buckets[k].count < minValue){
					minIndex = k;
					minValue = buckets[k].count;
				}
			}

			if (minValue != 0){
				if (actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)){
					//System.out.println("incorrect eviction");
					problematicEvictions++;
				}
				totalEvictions++;
			}


			if (rankToFrequency != null && minValue!= 0 /*&& actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)*/){
				int curRank = flowToRank.get(buckets[minIndex].flowid);
				if (rankToFrequency.containsKey(curRank)){
					rankToFrequency.put(curRank, rankToFrequency.get(curRank) + 1);
				}
				else
					rankToFrequency.put(curRank, 1);
			}	

			buckets[minIndex].flowid = key;
			buckets[minIndex].count += 1;

			return;
		}

		for (k = 0; k < D; k++){
			int index = (int) ((hashA[k]*keyBeingCarried + hashB[k]) % P) % (tableSize/D) + (k*tableSize/D);
			int curKeyIndex = (int) ((hashA[k]*key + hashB[k]) % P) % (tableSize/D) + (k*tableSize/D);

			/*int index = (int) ((hashA[k]*keyBeingCarried + hashB[k]) % P) % (tableSize);
			int curKeyIndex = (int) ((hashA[k]*key + hashB[k]) % P) % (tableSize);*/

			if (type == SummaryStructureType.AsymmetricDleftSingleLookUp){
				/*int[] size = {294*tableSize/1024, 267*tableSize/1024, 243*tableSize/1024, 220*tableSize/1024};
				int[] cumSize = {0, 294*tableSize/1024, 561*tableSize/1024, 804*tableSize/1024};*/

				int[] size = {213*tableSize/1024, 194*tableSize/1024, 177*tableSize/1024, 161*tableSize/1024, 146*tableSize/1024, 133*tableSize/1024};
				int[] cumSize = {0, 213*tableSize/1024, 407*tableSize/1024, 584*tableSize/1024, 745*tableSize/1024, 891*tableSize/1024};

				index = (int) ((hashA[k]*keyBeingCarried + hashB[k]) % P) % (size[k]) + (cumSize[k]);
				curKeyIndex = (int) ((hashA[k]*key + hashB[k]) % P) % (size[k]) + (cumSize[k]);
			}

			if (k == 0) firstLocation = index;
			
			if (type == SummaryStructureType.RollingMinWithBloomFilter || type == SummaryStructureType.RollingMinWihoutCoalescense){
				//if (isNew){
					//zeroing out, or coalescing multipe occurences of the same flow
					/*if (keyBeingCarried == key && k != 0)
						System.out.println("Safety check failed");*/

					if (buckets[curKeyIndex].flowid == key && k != 0){
						if (buckets[firstLocation].flowid != key){
							System.out.println("causing inconsistency " + k);
						}

						

						// coalenscence case
						if (type != SummaryStructureType.RollingMinWihoutCoalescense){
							buckets[firstLocation].count += buckets[curKeyIndex].count; // handled by the next packet coz it goes back on table stages
							buckets[curKeyIndex].flowid = 0;
							buckets[curKeyIndex].count = 0;
						 	// how would this manifest in a multi stage table - can you break out
						}
						else{
							
							buckets[curKeyIndex].count++; // for this packet
							/*if (buckets[curKeyIndex].flowid == 1110210987)
								System.out.println("incrementing in table "+ k + " trial#" + keynum + " value" + buckets[curKeyIndex].count);*/
							// causes multiple occurences
						}
						if (buckets[curKeyIndex].flowid == 0 && buckets[curKeyIndex].count != 0){
							System.out.println("inconsistency case 5");
						}

						if (buckets[firstLocation].flowid == 0 && buckets[firstLocation].count != 0){
							System.out.println("firstLocation = " + firstLocation + " " + buckets[firstLocation].flowid + " " + buckets[firstLocation].count);
							System.out.println("inconsistency case 6");
						}
					}

					// new flow - this may have been zeroed out from the previous case, so idk how to handle that in hardware
					if (buckets[index].flowid == 0 && k != 0) {
						buckets[index].flowid = keyBeingCarried;
						buckets[index].count = valueBeingCarried;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("just storing trial #" + keynum + " value" + buckets[index].count);*/

						//bloomfilter.add(key);

						//clear out the current value being carried, but continue process to update on the key
						if (type == SummaryStructureType.RollingMinWihoutCoalescense){
							keyBeingCarried = 0;
							valueBeingCarried = 0;
						}
						else
							break;
					}
					else if (buckets[index].flowid == keyBeingCarried){ // retain the later value alone
						keyBeingCarried = 0;
						valueBeingCarried = 0;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("just ignoring trial #" + keynum + " value" + buckets[index].count);*/
					}

					if (buckets[index].flowid == key && k == 0){
						buckets[index].count++;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("incrementing in table 0 trial#" + keynum + " value" + buckets[index].count);*/
						
						// but continue process to update on the key that came in
						if (type != SummaryStructureType.RollingMinWihoutCoalescense)
							break; // how would this manifest in a multi stage table - can you break out
					}
					else if (k == 0){
						// place the new value here and carry the rest over
						valueBeingCarried = buckets[index].count;
						keyBeingCarried = buckets[index].flowid;

						/*if (buckets[index].flowid == 1110210987 && key != 1110210987)
								System.out.println("kicking out from first table trial#" + keynum + " value" + buckets[index].count);*/

						buckets[index].flowid = key;
						buckets[index].count = 1; // minValue + 1 insertion here ??

						if (buckets[index].flowid == 0 && buckets[index].count != 0){
							System.out.println("inconsistency case 3");
						}

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("inserting in table1 trial #" + keynum + " value" + buckets[index].count);*/

						//System.out.println("index = " + index + " " + buckets[index].flowid + " " + buckets[index].count);
					}
					else if (buckets[index].count < valueBeingCarried){
					// swap out key being carried for value in this location
						/*if (buckets[index].flowid == 1110210987 && keyBeingCarried != 1110210987)
								System.out.println("kicking out from first table " + k + " trial#" + keynum + " value" + buckets[index].count);*/

						long temp = valueBeingCarried;
						valueBeingCarried = buckets[index].count;
						buckets[index].count = temp;

						temp = keyBeingCarried;
						keyBeingCarried = buckets[index].flowid;
						buckets[index].flowid = temp;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("inserting in table " + k + " trial #" + keynum + " value" + buckets[index].count);*/

						if (buckets[index].flowid == 0 && buckets[index].count != 0){
							System.out.println("inconsistency case 4");
						}
					}

					
					
				/*}
				else{
					// TODO: more cases here since false positives are possible
					if (buckets[index].flowid == key){
						buckets[index].count++;
					}
				}*/
				if (!bloomfilter.contains(key))
					bloomfilter.add(key);
			}
			
			else if (type == SummaryStructureType.RollingMinSingleLookup || type == SummaryStructureType.AsymmetricDleftSingleLookUp){

					// new flow - this may have been zeroed out from the previous case, so idk how to handle that in hardware
					if (buckets[index].flowid == 0 && k == 0) {
						buckets[index].flowid = key;
						buckets[index].count = 1;
						break;
					}
					else if (buckets[index].flowid == 0 && k != 0) {
						buckets[index].flowid = keyBeingCarried;
						buckets[index].count = valueBeingCarried;

						break;
					}
					else if (buckets[index].flowid == keyBeingCarried){ // coalesce the values
						buckets[index].count += valueBeingCarried;
						break; // hardware?
					}

					if (buckets[index].flowid == key && k == 0){ // updated value
						notMatched = false;
						buckets[index].count++;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("incrementing in table 0 trial#" + keynum + " value" + buckets[index].count);*/
						break;
					}
					else if (k == 0){
						// place the new value here and carry the rest over
						valueBeingCarried = buckets[index].count;
						keyBeingCarried = buckets[index].flowid;

						/*if (buckets[index].flowid == 1110210987 && key != 1110210987)
								System.out.println("kicking out from first table trial#" + keynum + " value" + buckets[index].count);*/

						buckets[index].flowid = key;
						buckets[index].count = 1; // minValue + 1 insertion here ??

						if (buckets[index].flowid == 0 && buckets[index].count != 0){
							System.out.println("inconsistency case 3");
						}
						firstLocation = index;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("inserting in table1 trial #" + keynum + " value" + buckets[index].count);*/

						//System.out.println("index = " + index + " " + buckets[index].flowid + " " + buckets[index].count);
					}
					else if (buckets[index].count < valueBeingCarried){
					// swap out key being carried for value in this location
						/*if (buckets[index].flowid == 1110210987 && keyBeingCarried != 1110210987)
								System.out.println("kicking out from first table " + k + " trial#" + keynum + " value" + buckets[index].count);*/

						long temp = valueBeingCarried;
						valueBeingCarried = buckets[index].count;
						buckets[index].count = temp;

						temp = keyBeingCarried;
						keyBeingCarried = buckets[index].flowid;
						buckets[index].flowid = temp;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("inserting in table " + k + " trial #" + keynum + " value" + buckets[index].count);*/

						if (buckets[index].flowid == 0 && buckets[index].count != 0){
							System.out.println("inconsistency case 4");
						}
					}

					if (actualFlowSizes.get(keyBeingCarried) > actualFlowSizes.get(key)){
					//System.out.println("incorrect eviction");
						problematicEvictions++;
					}
					totalEvictions++;

					/*if (k == D - 1 && notMatched)
						buckets[firstLocation].count += valueBeingCarried;*/

					if (k == D - 1 && rankToFrequency != null /*&& actualFlowSizes.get(keyBeingCarried) > actualFlowSizes.get(key)*/){
						int curRank = flowToRank.get(keyBeingCarried);
						if (rankToFrequency.containsKey(curRank)){
							rankToFrequency.put(curRank, rankToFrequency.get(curRank) + 1);
						}
						else
							rankToFrequency.put(curRank, 1);
					}


					
				/*}
				else{
					// TODO: more cases here since false positives are possible
					if (buckets[index].flowid == key){
						buckets[index].count++;
					}
				}*/
				if (!bloomfilter.contains(key))
					bloomfilter.add(key);
			}
			else{
				// this flow has been seen before
				if (buckets[index].flowid == key) {
					buckets[index].count++;
					break;
				}

				// new flow
				if (buckets[index].flowid == 0) {
					buckets[index].flowid = key;
					buckets[index].count = 1;
					break;
				}

				// track min - first time explicitly set the value
				if (buckets[index].count < minValue || k == 0){
					minValue = buckets[index].count;
					minIndex = index;
				}
			}
		}

		boolean isAggregateData = false;
		// none of the D locations were free
		if (k == D) {
			//packetsInfoDroppedAtFlow[packets.get(j) - 1]++;
			if (type == SummaryStructureType.DLeft)
				doNothing();
			else if (type == SummaryStructureType.BasicHeuristic)
				basicHeuristic(minIndex, key, false, 1, rankToFrequency);
			else if (type == SummaryStructureType.MinReplacementHeuristic)
				minReplacementHeuristic(minIndex, key);
			else if (type == SummaryStructureType.EvictionWithCount)
				evictionByComparisonWithCount(minIndex, key);
			else droppedPacketInfoCount += valueBeingCarried;
		}
	}

	public void processAggData(long key, int keynum, long value,  int[] nonHHCompetitors, HashSet<Long> expectedHH){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 9029;
		final int hashA[] = { 	421, 	199, 	79,	83,	89,	97,	101,	103,	107,	109,	113,
								127,	131,	137,	139,	149,	151,	157,	163,	167,	173,
								179,	181,	191,	193,	197,	199,	211,	223,	227,	229,
								233,	239,	241,	251,	257,	263,	269,	271,	277,	281,
								283,	293,	307,	311,	313,	317,	331,	337,	347,	349,
								353,	359,	367,	373,	379,	383,	389,	397,	401,	409,
								419,	421,	431,	433,	439,	443,	449,	457,	461,	463,
								467,	479,	487,	491,	499,	503,	509,	521,	523,	541,
								547,	557,	563,	569,	571,	577,	587,	593,	599,	601,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1229,	1231,	1237,	1249,	1259,	1277,	1279,	1283,	1289,	1291,
								1297,	1301,	1303,	1307,	1319,	1321,	1327,	1361,	1367,	1373,
								1381,	1399,	1409,	1423,	1427,	1429,	1433,	1439,	1447,	1451};

			//421, 149, 311, 701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453};
		final int hashB[] = {   73, 	3079, 	613,	617,	619,	631,	641,	643,	647,	653,	659,
								661,	673,	677,	683,	691,	701,	709, 	719,	727,	733,
								739,	743,	751,	757,	761,	769,	773,	787,	797,	809,
								811,	821,	823,	827,	829,	839,	853,	857,	859, 	863,
								877,	881,	883,	887,	907,	911,	919,	929,	937,	941,
								947, 	953,	967,	971,	977,	983, 	991,	997, 	1009,	1013,
								1019,	1021,	1031,	1033,	1039,	1049,	1051,	1061,	1063,	1069,
								1087,	1091,	1093,	1097,	1103,	1109,	1117,	1123,	1129,	1151,
								1153,	1163,	1171,	1181,	1187,	1193,	1201,	1213,	1217,	1223,
								1453,	1459,	1471,	1481,	1483,	1487,	1489,	1493,	1499,	1511,
								1523,	1531,	1543,	1549,	1553,	1559,	1567,	1571,	1579,	1583,
								1597,	1601,	1607,	1609,	1613,	1619,	1621,	1627,	1637,	1657,
								3221, 	3229, 	3251, 	3253, 	3257,	3259, 	3271, 	3299,	3301, 	3307, 
								3313, 	3319, 	3323, 	3329, 	3331};


		totalNumberOfPackets++;

		// keep track of which of the d locations has the minimum lost packet count
		// use this location to place the incoming flow if there is a collision
		int minIndex = 0;
		long minValue = -1;
		long keyBeingCarried = key;
		long valueBeingCarried = value;

		/* uniform hashing into a chunk N/d and then dependent picking of the choice*/
		int k = 0;
		int firstLocation = 0; // how to track this in hardware

		int currentCompetitors = 0; // variable to track the current number of heavy hitter competitors the current packet has seen

		if (key == 0)
		{
			System.out.print("invalid Key");
			return;
		}

		for (k = 0; k < D; k++){
			int index = (int) ((hashA[k]*keyBeingCarried + hashB[k]) % P) % (tableSize/D) + (k*tableSize/D);
			int curKeyIndex = (int) ((hashA[k]*key + hashB[k]) % P) % (tableSize/D) + (k*tableSize/D);

			if (k == 0) firstLocation = index;
			
			if (type == SummaryStructureType.BasicHeuristic){
				// this flow has been seen before
				if (buckets[index].flowid == key) {
					buckets[index].count+= value;
					break;
				}

				// new flow
				if (buckets[index].flowid == 0) {
					buckets[index].flowid = key;
					buckets[index].count = value;
					break;
				}

				if (expectedHH.contains(buckets[index].flowid))
					currentCompetitors++;

				// track min - first time explicitly set the value
				if (buckets[index].count < minValue || k == 0){
					minValue = buckets[index].count;
					minIndex = index;
				}
			}
			else if (type == SummaryStructureType.RollingMinSingleLookup){
				if (buckets[index].flowid == keyBeingCarried) {
					buckets[index].count+= valueBeingCarried;
					break;
				}

				// new flow
				if (buckets[index].flowid == 0) {
					buckets[index].flowid = keyBeingCarried;
					buckets[index].count = valueBeingCarried;
					break;
				}

				if (expectedHH.contains(buckets[index].flowid))
					currentCompetitors++;

				// carry the min over in rolling fashion
				if (buckets[index].count < valueBeingCarried){
					long temp = valueBeingCarried;
					valueBeingCarried = buckets[index].count;
					buckets[index].count = temp;

					temp = keyBeingCarried;
					keyBeingCarried = buckets[index].flowid;
					buckets[index].flowid = temp;
				}
			}
		}

		nonHHCompetitors[currentCompetitors] += 1;

		boolean isAggregateData = true;
		// none of the D locations were free
		if (k == D) {
			//packetsInfoDroppedAtFlow[packets.get(j) - 1]++;
			if (type == SummaryStructureType.DLeft)
				doNothing();
			else if (type == SummaryStructureType.BasicHeuristic)
				basicHeuristic(minIndex, key, isAggregateData, value, null);
		}
	}

	public int getDroppedPacketInfoCount(){
		return droppedPacketInfoCount;
	}

	public double getProblematicEvictionFraction(){
		return problematicEvictions/totalEvictions;
	}

	public FlowWithCount[] getBuckets(){
		return buckets;
	}

	public int[] getKeysPerBucket(){
		return keysBeenInIndex;
	}

	public void printBuckets(){
		int stageSize = tableSize/D;
		for (int i = 0; i < stageSize; i++){
			for (int j = 0; j < D; j++)
				System.out.print(Long.toString(buckets[i + j*stageSize].flowid) + "," + buckets[i + j*stageSize].count +",,");
			System.out.println();
		}
	}

	public long[] getFlowIdBuckets(){
		return flowIdBuckets;
	}

	public Sketch getSketch(){
		if (type == SummaryStructureType.EvictionWithCount || type == SummaryStructureType.EvictionWithoutCount)
			return countMinSketch;
		else
			return null;
	}

	public void basicHeuristic(int minIndex, long key, boolean isAggregateData, long value, HashMap<Integer, Integer> rankToFrequency){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		if (isAggregateData){
			if (value > buckets[minIndex].count){
				droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count;
				buckets[minIndex].flowid = key;
				buckets[minIndex].count = value;
			}
			else
				droppedPacketInfoCount = droppedPacketInfoCount + (int) value;
		}
		else {
			if (actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)){
				//System.out.println("incorrect eviction");
				problematicEvictions++;
			}
			totalEvictions++;

			if (rankToFrequency != null /*&& actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)*/){
				int curRank = flowToRank.get(buckets[minIndex].flowid);
				if (rankToFrequency.containsKey(curRank)){
					rankToFrequency.put(curRank, rankToFrequency.get(curRank) + 1);
				}
				else
					rankToFrequency.put(curRank, 1);
			}	

			droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count;
			buckets[minIndex].flowid = key;
			buckets[minIndex].count += 1; // replace with min+1

			
		}
	}

	public void minReplacementHeuristic(int minIndex, long key){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count;
		buckets[minIndex].flowid = key;
		buckets[minIndex].count += 1;
	}

	public void doNothing(){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		droppedPacketInfoCount++;
	}

	public void evictionByComparisonWithCount(int minIndex, long key){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		if (countMinSketch.estimateCount(buckets[minIndex].flowid) < countMinSketch.estimateCount(key)){
			//packetsInfoDroppedAtFlow[packets.get(j) - 1] = 0;
			//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
			droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count - (int) countMinSketch.estimateCount(key);
			buckets[minIndex].flowid = key;
			buckets[minIndex].count = (int) countMinSketch.estimateCount(key);
		}
		else{
			//packetsInfoDroppedAtFlow[packets.get(j) - 1]++;
			droppedPacketInfoCount++;
		}
	}
	
}