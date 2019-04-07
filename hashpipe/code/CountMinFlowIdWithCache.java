import java.util.*;
import java.math.BigInteger;

/* hash table simulation to track the unique flows experiencing loss
	using the D-Left hashing procedure where each flow id is hashed exactly
	d times to generate d locations where the flow and its loss might be
	stored* */

public class CountMinFlowIdWithCache{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private int totalNumberOfPackets;

	private Sketch countMinSketch;
	private FlowIdWithCount[] cache;
	private int cacheSize;
	private HashMap<String, Long> heavyhitterList;
	private boolean[] reportedToController;

	private SummaryStructureType type;
	private final int numHashFunctions;

	private final double threshold;
	private int controllerAction;
	private int k;
	private BigInteger[] hashBigA;
	private BigInteger[] hashBigB;
	private BigInteger bigP;
	private int flag;

	public CountMinFlowIdWithCache(int totalMemory, SummaryStructureType type, int numberOfFlows, int D, int cacheSize, double threshold, int k){
		this.tableSize = tableSize;
		this.numHashFunctions = D;
		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		totalNumberOfPackets = 0;
		controllerAction = 0;
		this.flag = 1;

		this.type = type;
		this.cacheSize = cacheSize;
		this.threshold = threshold;
		this.k = k;

		//System.out.println(this.threshold + "threshold in constructor");
		
		cache = new FlowIdWithCount[cacheSize];		
		for (int j = 0; j < cacheSize; j++){
			cache[j] = new FlowIdWithCount("", 0);
		}

		if (type == SummaryStructureType.CountMinCacheNoKeys)
			countMinSketch = new Sketch((totalMemory /*- cacheSize*/)/numHashFunctions, numHashFunctions, numberOfFlows);
		else
			countMinSketch = new Sketch(totalMemory/numHashFunctions, numHashFunctions, numberOfFlows);
		heavyhitterList = new HashMap<String, Long>();
		
		if (type == SummaryStructureType.CountMinCacheNoKeysReportedBit)
			reportedToController = new boolean[cacheSize];

		hashBigA = new BigInteger[numHashFunctions];
		hashBigB = new BigInteger[numHashFunctions];
		bigP = new BigInteger(Long.toString(39916801));
		for (int i = 0; i < numHashFunctions; i++){
			hashBigA[i] = new BigInteger(Integer.toString((int) (Math.random()* 39916801)));
			hashBigB[i] = new BigInteger(Integer.toString((int) (Math.random()* 39916801)));
		}
	}

	public void processData(String key, long thr_totalPackets){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 5171;
		final int hashB[] = {  199, 2719, 2851, 1453};
		final int hashA[] = {  3079, 2341, 179, 1213};
		totalNumberOfPackets++;

		// update the count-min sketch for this flowid
		// TODO: modify this to update and read minimum parallelly so that
		// there is no going back to previously updated stages involved
		countMinSketch.updateCountInSketchBigHash(key);

		if (totalNumberOfPackets > thr_totalPackets && countMinSketch.estimateCountBigHash(key) > threshold * 10000000){
			//System.out.println(countMinSketch.estimateCountBigHash(key));
			//System.out.println(threshold*10000000);
			/* hash to find index in cache and update*/
			//int curKeyIndex = (int) ((hashA[0]*key + hashB[0]) % P) % (cacheSize);
			BigInteger bigint = new BigInteger(key);
			bigint = bigint.multiply(hashBigA[0]);
			bigint = bigint.add(hashBigB[0]);
			bigint = bigint.mod(bigP);
			bigint = bigint.mod(new BigInteger(Integer.toString(cacheSize)));
			int curKeyIndex = bigint.intValue();



			if (type == SummaryStructureType.CountMinCacheWithKeys){
				//int curKeyIndex = -1; // BOGUS
				/*if (!key.equals(cache[curKeyIndex].flowid)){

					// new key
					cache[curKeyIndex].flowid = key;
					cache[curKeyIndex].count = countMinSketch.estimateCountBigHash(key) - 1;
					heavyhitterList.put(key, countMinSketch.estimateCountBigHash(key));
					controllerAction++;
				}*/
				/*int i;
				for (i = 0; i < cache.length; i++)
					if (cache[i].count == 0) {
						cache[i].flowid = new String(key);
						cache[i].count = countMinSketch.estimateCountBigHash(key);
						break;
					}
					else if (key.equals(cache[i].flowid)){
						cache[i].count++;
						break;
					}

				if (i == cache.length && flag != 0){
					//System.out.println(totalNumberOfPackets);
					flag = 0;
				}*/
				if (cache[curKeyIndex].count == 0){
					cache[curKeyIndex].flowid = key;
					cache[curKeyIndex].count = countMinSketch.estimateCountBigHash(key);
				}
				else if (key.equals(cache[curKeyIndex].flowid))
					cache[curKeyIndex].count++;
			}
			else if (type == SummaryStructureType.CountMinCacheNoKeys){
				if (heavyhitterList.containsKey(key)){
					heavyhitterList.put(key, countMinSketch.estimateCountBigHash(key));
				} else {
					heavyhitterList.put(key, countMinSketch.estimateCountBigHash(key));
				}
				controllerAction++;
			}
			else if (type == SummaryStructureType.CountMinWithHeap){
				String minKey = "";
				long minCount = -1;
				boolean flag = false;
				for (String k : heavyhitterList.keySet()){
					if (flag == false || heavyhitterList.get(k) < minCount){
						minCount = heavyhitterList.get(k);
						minKey = k;
						flag = true;
					}
				}
				if (heavyhitterList.size() == k && countMinSketch.estimateCountBigHash(key) > minCount){
					heavyhitterList.put(key, countMinSketch.estimateCountBigHash(key));
					heavyhitterList.remove(minKey);
				} 
				else if (heavyhitterList.size() < k)
					heavyhitterList.put(key, countMinSketch.estimateCountBigHash(key));
			}
		}
	}

	public int getDroppedPacketInfoCount(){
		return droppedPacketInfoCount;
	}

	public FlowIdWithCount[] getCache(){
		return cache;
	}

	public HashMap<String, Long> getHeavyHitters(){
		return heavyhitterList;
	}

	public Sketch getSketch(){
		return countMinSketch;
	}

	public int getControllerReports(){
		return controllerAction;
	}	
}