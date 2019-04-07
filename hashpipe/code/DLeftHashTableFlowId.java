import java.util.*;
import java.math.BigInteger;

/* hash table simulation to track the unique flows experiencing loss
	using the D-Left hashing procedure where each flow id is hashed exactly
	d times to generate d locations where the flow and its loss might be
	stored* */

public class DLeftHashTableFlowId{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private double problematicEvictions;
	private double totalEvictions;
	private int totalNumberOfPackets;

	private Sketch countMinSketch;
	private FlowIdWithCount[] buckets;
	private int[] keysBeenInIndex;
	private String[] flowIdBuckets;
	private HashSet<String> bloomfilter;

	private SummaryStructureType type;
	private final int D;
	private HashMap<String, Integer> actualFlowSizes;
	private HashMap<String, Integer> flowToRank;
	private final BigInteger[] bigHashSeedA;
	private final BigInteger[] bigHashSeedB;
	private final BigInteger bigP;
	private final long primeNumber;

	public DLeftHashTableFlowId(int tableSize, SummaryStructureType type, int numberOfFlows, int D, HashMap<String,Integer> flowSizes){
		this.tableSize = tableSize;
		this.D = D;
		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		problematicEvictions = 0;
		totalEvictions = 0;
		totalNumberOfPackets = 0;
		this.actualFlowSizes = flowSizes;

		this.primeNumber = 39916801;
		bigP = new BigInteger(Long.toString(primeNumber));
		bigHashSeedA = new BigInteger[D];
		bigHashSeedB = new BigInteger[D];
		for (int i = 0; i < D; i++){
			bigHashSeedA[i] = new BigInteger(Long.toString((long) (Math.random()* primeNumber)));
			bigHashSeedB[i] = new BigInteger(Long.toString((long) (Math.random() * primeNumber)));
		}

		// given input, so ideal order of heavy hitters
		ArrayList<FlowIdWithCount> flowSizesList = new ArrayList<FlowIdWithCount>();
		for (String f : flowSizes.keySet()){
			flowSizesList.add(new FlowIdWithCount(f, flowSizes.get(f)));
		}
		FlowIdWithCount[] inputFlowArray = new FlowIdWithCount[flowSizesList.size()];
		inputFlowArray = flowSizesList.toArray(inputFlowArray);
		Arrays.sort(inputFlowArray);

		// get the ranks of all flows and populate rank map
		flowToRank = new HashMap<String, Integer>();
		for (int i = 0; i < inputFlowArray.length; i++){
			flowToRank.put(inputFlowArray[i].flowid, i + 1);
		}


		this.type = type;

		if (type == SummaryStructureType.DLeft || type == SummaryStructureType.BasicHeuristic || type == SummaryStructureType.MinReplacementHeuristic || type == SummaryStructureType.OverallMinReplacement){
			buckets = new FlowIdWithCount[tableSize];
			keysBeenInIndex = new int[tableSize];
		
			for (int j = 0; j < tableSize; j++){
				buckets[j] = new FlowIdWithCount("", 0);
			}
		}
		else if (type == SummaryStructureType.EvictionWithCount){
			buckets = new FlowIdWithCount[tableSize];
		
			for (int j = 0; j < tableSize; j++){
				buckets[j] = new FlowIdWithCount("", 0);
			}

			countMinSketch = new Sketch(tableSize/3, 3, numberOfFlows);
		}
		else if (type == SummaryStructureType.RollingMinWithBloomFilter || type == SummaryStructureType.RollingMinWihoutCoalescense || type == SummaryStructureType.RollingMinSingleLookup || type == SummaryStructureType.AsymmetricDleftSingleLookUp){
			buckets = new FlowIdWithCount[tableSize];

			for (int j = 0; j < tableSize; j++){
				buckets[j] = new FlowIdWithCount("",0);
			}

			//bloom filter
			bloomfilter = new HashSet<String>();
		}
		else {
			flowIdBuckets = new String[tableSize];
		
			for (int j = 0; j < tableSize; j++){
				flowIdBuckets[j] = "";
			}

			countMinSketch = new Sketch(tableSize/3, 3, numberOfFlows);
		}
	}

	public void processData(String key, int keynum, HashMap<Integer, Integer> rankToFrequency){
		if (type == SummaryStructureType.EvictionWithoutCount)
			processDataWithoutCountInTable(key);
		else
			processDataWithCountInTable(key, keynum, rankToFrequency);
	}

	public int hashBig(String key, int hashFunctionIndex, int cursize){
		/*long curHash = 0;
		long x = 18;
		for (int i = 0; i < key.length(); i++){
			curHash = x*curHash + (long)(key.charAt(i));
			curHash = curHash % primeNumber;
		}
		int curKeyIndex = (int) (curHash % (long) cursize);*/
		BigInteger bigint = new BigInteger(key);
		bigint = bigint.multiply(bigHashSeedA[hashFunctionIndex]);
		bigint = bigint.add(bigHashSeedB[hashFunctionIndex]);
		bigint = bigint.mod(bigP);
		bigint = bigint.mod(new BigInteger(Integer.toString(cursize)));
		int curKeyIndex = bigint.intValue();
		return curKeyIndex;
	}

	public void processDataWithoutCountInTable(String key){
		// hardcoded values for the hash functions given that the number of flows is 100

			//73, 109, 233, 31, 151, 3359, 643, 1103, 2927, 3061, 409, 3079, 2341, 179, 1213
		totalNumberOfPackets++;

		// update the count-min sketch for this flowid
		countMinSketch.updateCountInSketchBigHash(key);

		/* uniform hashing into a chunk N/d and then dependent picking of the choice*/
		int k = 0;

		// keep track of which of the d locations has the minimum lost packet count
		// use this location to place the incoming flow if there is a collision
		int minIndex = 0;
		int minValue = -1;

		for (k = 0; k < D; k++){
			int index = hashBig(key, k, tableSize/D) + (k*tableSize/D);
								
			// this flow has been seen before
			if (flowIdBuckets[index] == key) {
				break;
			}

			// new flow
			if (flowIdBuckets[index].equals("")) {
				flowIdBuckets[index] = key;
				break;
			}

			// track min - first time explicitly set the value
			if (countMinSketch.estimateCountBigHash(flowIdBuckets[index]) < minValue || k == 0){
				minValue = (int) countMinSketch.estimateCountBigHash(flowIdBuckets[index]);
				minIndex = index;
			}
		}

		// TODO: figure out if the incoming flow has a higher loss than one of the existing flows in the table
		// find a way of tracking the information of the incoming flow because it isnt the hash table
		// so we don't have information on what its loss count is nd the very first time it comes in, loss is 0
		if (k == D) {
			//System.out.println("Min Index: " + minIndex + "minValue: " + minValue + "current id: " + packets.get(j) + "existing id: " + buckets[minIndex]);
			if (countMinSketch.estimateCountBigHash(flowIdBuckets[minIndex]) < countMinSketch.estimateCountBigHash(key)){
				//packetsInfoDroppedAtFlow[packets.get(j) - 1] = 0;
				//packetsInfoDroppedAtFlow[buckets[minIndex] - 1] = (int) countMinSketch.estimateCountBigHash(buckets[minIndex]);
				droppedPacketInfoCount = droppedPacketInfoCount + (int) countMinSketch.estimateCountBigHash(flowIdBuckets[minIndex]) - (int) countMinSketch.estimateCountBigHash(key);
				flowIdBuckets[minIndex] = key;
			}
			else{
				//packetsInfoDroppedAtFlow[packets.get(j) - 1]++;
				droppedPacketInfoCount++;
			}
		}
	}

	public void processDataWithCountInTable(String key, int keynum, HashMap<Integer, Integer> rankToFrequency){
		// hardcoded values for the hash functions given that the number of flows is 10

		totalNumberOfPackets++;

		// keep track of which of the d locations has the minimum lost packet count
		// use this location to place the incoming flow if there is a collision
		int minIndex = 0;
		long minValue = -1;
		boolean isNew = false;
		String keyBeingCarried = key;
		long valueBeingCarried = 1;

		// update the count-min sketch for this flowid if the data type is so
		if (type == SummaryStructureType.EvictionWithCount)
			countMinSketch.updateCountInSketchBigHash(key);

		// Look up the bloomfilter for whether the key is expected
		if (type == SummaryStructureType.RollingMinWithBloomFilter){
			isNew = !(bloomfilter.contains(key));
		}

		/* uniform hashing into a chunk N/d and then dependent picking of the choice*/
		int k = 0;
		int firstLocation = 0; // how to track this in hardware
		boolean notMatched = true;

		if (key == "")
		{
			System.out.print("invalid Key");
			return;
		}

		if (type == SummaryStructureType.OverallMinReplacement){
			minIndex = 0;
			minValue = buckets[0].count;

			for (k = 0; k < buckets.length; k++){
				if (key.equals(buckets[k].flowid)){
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
				/*if (actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)){
					//System.out.println("incorrect eviction");
					problematicEvictions++;
				}*/
				totalEvictions++;
			}


			/*if (rankToFrequency != null && minValue!= 0 /*&& actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)){
				int curRank = flowToRank.get(buckets[minIndex].flowid);
				if (rankToFrequency.containsKey(curRank)){
					rankToFrequency.put(curRank, rankToFrequency.get(curRank) + 1);
				}
				else
					rankToFrequency.put(curRank, 1);
			}	*/

			buckets[minIndex].flowid = key;
			buckets[minIndex].count += 1;
			keysBeenInIndex[minIndex] += 1;
			return;
		}

		long globalMin = 0;
		for (k = 0; k < D; k++){
			int index = hashBig(keyBeingCarried, k, tableSize/D) + (k*tableSize/D);
			int curKeyIndex = hashBig(key, k, tableSize/D) + (k*tableSize/D);

			/*int index = (int) ((hashA[k]*keyBeingCarried + hashB[k]) % P) % (tableSize);
			int curKeyIndex = (int) ((hashA[k]*key + hashB[k]) % P) % (tableSize);*/

			if (type == SummaryStructureType.AsymmetricDleftSingleLookUp){
				/*int[] size = {294*tableSize/1024, 267*tableSize/1024, 243*tableSize/1024, 220*tableSize/1024};
				int[] cumSize = {0, 294*tableSize/1024, 561*tableSize/1024, 804*tableSize/1024};*/

				int[] size = {213*tableSize/1024, 194*tableSize/1024, 177*tableSize/1024, 161*tableSize/1024, 146*tableSize/1024, 133*tableSize/1024};
				int[] cumSize = {0, 213*tableSize/1024, 407*tableSize/1024, 584*tableSize/1024, 745*tableSize/1024, 891*tableSize/1024};

				index = hashBig(keyBeingCarried, k, size[k]) + (cumSize[k]);
				curKeyIndex = hashBig(key, k, size[k]) + (cumSize[k]);
			}

			if (k == 0) firstLocation = index;
			
			if (type == SummaryStructureType.RollingMinWithBloomFilter || type == SummaryStructureType.RollingMinWihoutCoalescense){
				//if (isNew){
					//zeroing out, or coalescing multipe occurences of the same flow
					/*if (keyBeingCarried == key && k != 0)
						System.out.println("Safety check failed");*/

					if (key.equals(buckets[curKeyIndex].flowid) && k != 0){
						if (!key.equals(buckets[firstLocation].flowid)){
							System.out.println("causing inconsistency " + k);
						}

						

						// coalenscence case
						if (type != SummaryStructureType.RollingMinWihoutCoalescense){
							buckets[firstLocation].count += buckets[curKeyIndex].count; // handled by the next packet coz it goes back on table stages
							buckets[curKeyIndex].flowid = "";
							buckets[curKeyIndex].count = 0;
						 	// how would this manifest in a multi stage table - can you break out
						}
						else{
							
							buckets[curKeyIndex].count++; // for this packet
							/*if (buckets[curKeyIndex].flowid == 1110210987)
								System.out.println("incrementing in table "+ k + " trial#" + keynum + " value" + buckets[curKeyIndex].count);*/
							// causes multiple occurences
						}
						if (buckets[curKeyIndex].flowid.equals("") && buckets[curKeyIndex].count != 0){
							System.out.println("inconsistency case 5");
						}

						if (buckets[firstLocation].flowid.equals("") && buckets[firstLocation].count != 0){
							System.out.println("firstLocation = " + firstLocation + " " + buckets[firstLocation].flowid + " " + buckets[firstLocation].count);
							System.out.println("inconsistency case 6");
						}
					}

					// new flow - this may have been zeroed out from the previous case, so idk how to handle that in hardware
					if (buckets[index].flowid.equals("") && k != 0) {
						buckets[index].flowid = keyBeingCarried;
						buckets[index].count = valueBeingCarried;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("just storing trial #" + keynum + " value" + buckets[index].count);*/

						//bloomfilter.add(key);

						//clear out the current value being carried, but continue process to update on the key
						if (type == SummaryStructureType.RollingMinWihoutCoalescense){
							keyBeingCarried = "";
							valueBeingCarried = 0;
						}
						else
							break;
					}
					else if (buckets[index].flowid.equals(keyBeingCarried)){ // retain the later value alone
						keyBeingCarried = "";
						valueBeingCarried = 0;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("just ignoring trial #" + keynum + " value" + buckets[index].count);*/
					}

					if (buckets[index].flowid.equals(key) && k == 0){
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

						if (buckets[index].flowid.equals("") && buckets[index].count != 0){
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

						String temporary = new String(keyBeingCarried);
						keyBeingCarried = buckets[index].flowid;
						buckets[index].flowid = temporary;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("inserting in table " + k + " trial #" + keynum + " value" + buckets[index].count);*/

						if (buckets[index].flowid.equals("") && buckets[index].count != 0){
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
					/*if (k == 0) {
						globalMin = 500000;
						for (int x = 0; x < buckets.length; x++){
							if (buckets[x].count < globalMin){
								globalMin = buckets[x].count;
							}
						}
					}*/

					// new flow - this may have been zeroed out from the previous case, so idk how to handle that in hardware
					if (buckets[index].flowid.equals("") && k == 0) {
						buckets[index].flowid = key;
						buckets[index].count = 1;
						break;
					}
					else if (buckets[index].flowid.equals("") && k != 0) {
						buckets[index].flowid = keyBeingCarried;
						buckets[index].count = valueBeingCarried;

						break;
					}
					else if (buckets[index].flowid.equals(keyBeingCarried)){ // coalesce the values
						buckets[index].count += valueBeingCarried;
						break; // hardware?
					}

					if (buckets[index].flowid.equals(key) && k == 0){ // updated value
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

						if (buckets[index].flowid.equals("") && buckets[index].count != 0){
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

						String temporary = new String(keyBeingCarried);
						keyBeingCarried = buckets[index].flowid;
						buckets[index].flowid = temporary;

						/*if (buckets[index].flowid == 1110210987)
								System.out.println("inserting in table " + k + " trial #" + keynum + " value" + buckets[index].count);*/

						if (buckets[index].flowid.equals("") && buckets[index].count != 0){
							System.out.println("inconsistency case 4");
						}
					}


					/*if (actualFlowSizes.get(keyBeingCarried) > actualFlowSizes.get(key)){
					//System.out.println("incorrect eviction");
						problematicEvictions++;
					}*/
					totalEvictions++;

					/*if (k == D - 1 && notMatched)
						buckets[firstLocation].count += valueBeingCarried;*/

					/*if (k == D - 1 && rankToFrequency != null /*&& actualFlowSizes.get(keyBeingCarried) > actualFlowSizes.get(key)){
						int curRank = flowToRank.get(keyBeingCarried);
						if (rankToFrequency.containsKey(curRank)){
							rankToFrequency.put(curRank, rankToFrequency.get(curRank) + 1);
						}
						else
							rankToFrequency.put(curRank, 1);
					}*/
					//if (k == D - 1 && totalNumberOfPackets%100 == 0) System.err.println(valueBeingCarried + "," + globalMin);


					
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
				if (buckets[index].flowid.equals(key)) {
					buckets[index].count++;
					break;
				}

				// new flow
				if (buckets[index].flowid.equals("")) {
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

	public void processAggData(String key, int keynum, long value,  int[] nonHHCompetitors, HashSet<String> expectedHH){


		totalNumberOfPackets++;

		// keep track of which of the d locations has the minimum lost packet count
		// use this location to place the incoming flow if there is a collision
		int minIndex = 0;
		long minValue = -1;
		String keyBeingCarried = key;
		long valueBeingCarried = value;

		/* uniform hashing into a chunk N/d and then dependent picking of the choice*/
		int k = 0;
		int firstLocation = 0; // how to track this in hardware

		int currentCompetitors = 0; // variable to track the current number of heavy hitter competitors the current packet has seen

		if (key.equals(""))
		{
			System.out.print("invalid Key");
			return;
		}

		for (k = 0; k < D; k++){
			int index = hashBig(keyBeingCarried, k, tableSize/D) + (k*tableSize/D);
			int curKeyIndex = hashBig(key, k, tableSize/D) + (k*tableSize/D);

			if (k == 0) firstLocation = index;
			
			if (type == SummaryStructureType.BasicHeuristic){
				// this flow has been seen before
				if (buckets[index].flowid.equals(key)) {
					buckets[index].count+= value;
					break;
				}

				// new flow
				if (buckets[index].flowid.equals("")) {
					buckets[index].flowid = key;
					buckets[index].count = value;
					keysBeenInIndex[index]++;
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
				if (buckets[index].flowid.equals("")) {
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

					String temporary = new String(keyBeingCarried);
					keyBeingCarried = buckets[index].flowid;
					buckets[index].flowid = temporary;
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

	public FlowIdWithCount[] getBuckets(){
		return buckets;
	}

	public int[] getKeysPerBucket(){
		return keysBeenInIndex;
	}

	public void printBuckets(){
		int stageSize = tableSize/D;
		for (int i = 0; i < stageSize; i++){
			for (int j = 0; j < D; j++)
				System.out.print((buckets[i + j*stageSize].flowid) + "," + buckets[i + j*stageSize].count +",,");
			System.out.println();
		}
	}

	public String[] getFlowIdBuckets(){
		return flowIdBuckets;
	}

	public Sketch getSketch(){
		if (type == SummaryStructureType.EvictionWithCount || type == SummaryStructureType.EvictionWithoutCount)
			return countMinSketch;
		else
			return null;
	}

	public void basicHeuristic(int minIndex, String key, boolean isAggregateData, long value, HashMap<Integer, Integer> rankToFrequency){
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
			/*if (actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)){
				//System.out.println("incorrect eviction");
				problematicEvictions++;
			}*/
			totalEvictions++;

			/*if (rankToFrequency != null /*&& actualFlowSizes.get(buckets[minIndex].flowid) > actualFlowSizes.get(key)){
				int curRank = flowToRank.get(buckets[minIndex].flowid);
				if (rankToFrequency.containsKey(curRank)){
					rankToFrequency.put(curRank, rankToFrequency.get(curRank) + 1);
				}
				else
					rankToFrequency.put(curRank, 1);
			}	*/

			droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count;
			buckets[minIndex].flowid = key;
			buckets[minIndex].count += 1; // replace with min+1
			keysBeenInIndex[minIndex] += 1;			
		}
	}

	public void minReplacementHeuristic(int minIndex, String key){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count;
		buckets[minIndex].flowid = key;
		buckets[minIndex].count += 1;
	}

	public void doNothing(){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		droppedPacketInfoCount++;
	}

	public void evictionByComparisonWithCount(int minIndex, String key){
		//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
		if (countMinSketch.estimateCountBigHash(buckets[minIndex].flowid) < countMinSketch.estimateCountBigHash(key)){
			//packetsInfoDroppedAtFlow[packets.get(j) - 1] = 0;
			//packetsInfoDroppedAtFlow[buckets[minIndex].flowid - 1] = (int) buckets[minIndex].count;
			droppedPacketInfoCount = droppedPacketInfoCount + (int) buckets[minIndex].count - (int) countMinSketch.estimateCountBigHash(key);
			buckets[minIndex].flowid = key;
			buckets[minIndex].count = (int) countMinSketch.estimateCountBigHash(key);
		}
		else{
			//packetsInfoDroppedAtFlow[packets.get(j) - 1]++;
			droppedPacketInfoCount++;
		}
	}
	
}