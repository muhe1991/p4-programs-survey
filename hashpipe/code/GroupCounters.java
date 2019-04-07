import java.util.*;

/* hash table simulation to track the unique flows experiencing loss
	using the D-Left hashing procedure where each flow id is hashed exactly
	d times to generate d locations where the flow and its loss might be
	stored* */

public class GroupCounters{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private int totalNumberOfPackets;

	private FlowWithCount[] table;
	private long[] totalCount;
	private HashMap<Long, Long> heavyhitterList;

	private SummaryStructureType type;
	private final int numHashFunctions;

	public GroupCounters(int totalMemory, SummaryStructureType type, int numberOfFlows, int D){
		this.tableSize = totalMemory/4;
		// keys take twice as much space as counters and 2 sets of counters
		this.numHashFunctions = D;

		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		totalNumberOfPackets = 0;

		this.type = type;
		
		table = new FlowWithCount[tableSize];	
		totalCount = new long[tableSize];	
		for (int j = 0; j < tableSize; j++){
			table[j] = new FlowWithCount(0, 0);
		}

		heavyhitterList = new HashMap<Long, Long>();
	}

	public void processData(long key){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 5171;
		final int hashA[] = {  421, 149, 311, 701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453};
		final int hashB[] = {  73, 109, 233, 31, 151, 3359, 643, 1103, 2927, 3061, 409, 3079, 2341, 179, 1213};

		totalNumberOfPackets++;

		int curKeyIndex = (int) ((hashA[0]*key + hashB[0]) % P) % (tableSize);

		if (table[curKeyIndex].count == 0){
			table[curKeyIndex].flowid = key;
		}

		if (table[curKeyIndex].flowid == key)
			table[curKeyIndex].count++;
		else
			table[curKeyIndex].count--;
		totalCount[curKeyIndex]++;		
	}

	public int getDroppedPacketInfoCount(){
		return droppedPacketInfoCount;
	}

	public FlowWithCount[] getBuckets(){
		return table;
	}

	public long[] getTotalCounter(){
		return totalCount;
	}	
}