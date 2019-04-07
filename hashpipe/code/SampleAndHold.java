import java.util.*;

/*+----------------------------------------------------------------------
 ||
 ||  Class SampleAndHold 
 ||
 ||         Author:  Vibhaa Sivaraman
 ||
 ||        Purpose:  To simulate the sample and hold method proposed by 
 || 	   Estan and Varghese where packets are sampled with a certain
 ||		   probability, but once a packet is sampled, all subsequent
 || 	   packets of that flow are counted
 ||
 ||  Inherits From:  None
 ||
 ||  Interfaces:  None
 ||
 |+-----------------------------------------------------------------------
 ||
 ||  Class Methods:  processData that does the sampleAndHold procedure 
 ||  on a given packet that belongs to a given new flow
 ||
 ++-----------------------------------------------------------------------*/

public class SampleAndHold{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private int totalNumberOfPackets;
	private double samplingProb;

	private HashMap<Long, Long> flowMemory;
	private HashMap<Long, Long> heavyhitterList;

	private SummaryStructureType type;

	public SampleAndHold(int totalMemory, SummaryStructureType type, int numberOfFlows, double samplingProb){
		this.tableSize = totalMemory;
		// keys take twice as much space as counters and 2 sets of counters

		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		totalNumberOfPackets = 0;

		this.type = type;
		this.samplingProb = samplingProb;
		
		flowMemory = new HashMap<Long, Long>();	
		/*for (int j = 0; j < tableSize; j++){
			flowMemory[j] = new FlowWithCount(0, 0);
		}*/

		heavyhitterList = new HashMap<Long, Long>();
	}

	public void processData(long key){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 5171;
		final int hashA[] = {  421, 149, 311, 701, 557, 1667, 773, 2017, 1783, 883, 307, 199, 2719, 2851, 1453};
		final int hashB[] = {  73, 109, 233, 31, 151, 3359, 643, 1103, 2927, 3061, 409, 3079, 2341, 179, 1213};

		totalNumberOfPackets++;

		int curKeyIndex = (int) ((hashA[0]*key + hashB[0]) % P) % (tableSize);

		if (flowMemory.containsKey(key))
			flowMemory.put(key, flowMemory.get(key) + 1);
		else if (Math.random() <= samplingProb)
			flowMemory.put(key, (long) 1);	
	}

	public int getDroppedPacketInfoCount(){
		return droppedPacketInfoCount;
	}

	public HashMap<Long, Long> getBuckets(){
		return flowMemory;
	}	
}