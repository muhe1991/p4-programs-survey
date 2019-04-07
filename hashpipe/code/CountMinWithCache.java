import java.util.*;

/* hash table simulation to track the unique flows experiencing loss
	using the D-Left hashing procedure where each flow id is hashed exactly
	d times to generate d locations where the flow and its loss might be
	stored* */

public class CountMinWithCache{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private int totalNumberOfPackets;

	private Sketch countMinSketch;
	private FlowWithCount[] cache;
	private int cacheSize;
	private HashMap<Long, Long> heavyhitterList;
	private boolean[] reportedToController;

	private SummaryStructureType type;
	private final int numHashFunctions;

	private final double threshold;
	private int controllerAction;
	private int k;

	public CountMinWithCache(int totalMemory, SummaryStructureType type, int numberOfFlows, int D, int cacheSize, double threshold, int k){
		this.tableSize = tableSize;
		this.numHashFunctions = D;
		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		totalNumberOfPackets = 0;
		controllerAction = 0;

		this.type = type;
		this.cacheSize = cacheSize;
		this.threshold = threshold;
		this.k = k;
		
		cache = new FlowWithCount[cacheSize];		
		for (int j = 0; j < cacheSize; j++){
			cache[j] = new FlowWithCount(0, 0);
		}

		if (type == SummaryStructureType.CountMinCacheNoKeys)
			countMinSketch = new Sketch((totalMemory /*- cacheSize*/)/numHashFunctions, numHashFunctions, numberOfFlows);
		else
			countMinSketch = new Sketch((totalMemory - 8*cacheSize)/numHashFunctions, numHashFunctions, numberOfFlows);
		heavyhitterList = new HashMap<Long, Long>();
		
		if (type == SummaryStructureType.CountMinCacheNoKeysReportedBit)
			reportedToController = new boolean[cacheSize];
	}

	public void processData(long key, long thr_totalPackets){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 5171;
		final int hashB[] = {  199, 2719, 2851, 1453};
		final int hashA[] = {  3079, 2341, 179, 1213};
		totalNumberOfPackets++;

		// update the count-min sketch for this flowid
		// TODO: modify this to update and read minimum parallelly so that
		// there is no going back to previously updated stages involved
		countMinSketch.updateCount(key);

		if (totalNumberOfPackets > thr_totalPackets && countMinSketch.estimateCount(key) > threshold * totalNumberOfPackets){
			/* hash to find index in cache and update*/
			int curKeyIndex = (int) ((hashA[0]*key + hashB[0]) % P) % (cacheSize);
			/*BigInteger bigint = BigInteger(key);
			bigint = bigint.multiply(hashBigA[0]);
			bigint = bigint.add(hashBigB[0]);
			bigint = bigint.mod(bigP);
			bigint = bigint.mod(BigInteger(Integer.toString(cacheSize)));
			int curKeyIndex = bigint.intValue();*/


			if (type == SummaryStructureType.CountMinCacheWithKeys){
				if (cache[curKeyIndex].flowid != key){
					// new key
					cache[curKeyIndex].flowid = key;
					cache[curKeyIndex].count = countMinSketch.estimateCount(key) - 1;
					heavyhitterList.put(key, countMinSketch.estimateCount(key));
					controllerAction++;
				}

				if (cache[curKeyIndex].count == 0)
					cache[curKeyIndex].count = countMinSketch.estimateCount(key);
				else
					cache[curKeyIndex].count++;
			}
			else if (type == SummaryStructureType.CountMinCacheNoKeys){
				if (heavyhitterList.containsKey(key)){
					heavyhitterList.put(key, countMinSketch.estimateCount(key));
				} else {
					heavyhitterList.put(key, countMinSketch.estimateCount(key));
				}
				controllerAction++;
			}
			else if (type == SummaryStructureType.CountMinWithHeap){
				long minKey = -1;
				long minCount = -1;
				boolean flag = false;
				for (Long k : heavyhitterList.keySet()){
					if (flag == false || heavyhitterList.get(k) < minCount){
						minCount = heavyhitterList.get(k);
						minKey = k;
						flag = true;
					}
				}
				if (heavyhitterList.size() == k && countMinSketch.estimateCount(key) > minCount){
					heavyhitterList.put(key, countMinSketch.estimateCount(key));
					heavyhitterList.remove(minKey);
				} 
				else if (heavyhitterList.size() < k)
					heavyhitterList.put(key, countMinSketch.estimateCount(key));
			}
		}
	}

	public int getDroppedPacketInfoCount(){
		return droppedPacketInfoCount;
	}

	public FlowWithCount[] getCache(){
		return cache;
	}

	public HashMap<Long, Long> getHeavyHitters(){
		return heavyhitterList;
	}

	public Sketch getSketch(){
		return countMinSketch;
	}

	public int getControllerReports(){
		return controllerAction;
	}	
}