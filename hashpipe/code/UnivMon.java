import java.util.*;

/*+----------------------------------------------------------------------
 ||
 ||  Class UnivMon
 ||
 ||         Author:  Vibhaa Sivaraman
 ||
 ||        Purpose:  To simulate the UnivMon algorithm
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

public class UnivMon{
	private int tableSize;
	private int droppedPacketInfoCount;
	private int cumDroppedPacketInfoCount;
	private int totalNumberOfPackets;
	private int numberOfSubstreams;
	private int k;

	private HashMap<Long, Long> flowMemory;
	private Sketch cSketches[];
	private ArrayList<HashMap<Long, Long>> heavyhitterList;
	private ArrayList<LinkedList<ArrayList<FlowWithCount>>> topKinSubstreams;
	private double[] l2InSubstreams;
	private double[] oldL2inSubstream;
	private double threshold;

	private SummaryStructureType type;

	public UnivMon(int totalMemory, SummaryStructureType type, int numberOfPackets, int k, double threshold){
		this.tableSize = totalMemory;
		// keys take twice as much space as counters and 2 sets of counters

		droppedPacketInfoCount = 0;
		cumDroppedPacketInfoCount = 0;
		totalNumberOfPackets = numberOfPackets;
		this.numberOfSubstreams = 0;
		this.k = k;

		this.type = type;
		this.threshold = threshold;
		
		flowMemory = new HashMap<Long, Long>();	
		/*for (int j = 0; j < tableSize; j++){
			flowMemory[j] = new FlowWithCount(0, 0);
		}*/

		cSketches = new Sketch[numberOfSubstreams + 1]; // extra zero level
		l2InSubstreams = new double[numberOfSubstreams + 1];
		oldL2inSubstream = new double[numberOfSubstreams + 1];

		heavyhitterList = new ArrayList<HashMap<Long, Long>>(numberOfSubstreams + 1);
		topKinSubstreams = new ArrayList<LinkedList<ArrayList<FlowWithCount>>>(numberOfSubstreams + 1);
		for (int i = 0; i <= numberOfSubstreams; i++){
			//cSketches[i] = new Sketch(totalMemory/numberOfSubstreams/3, 3, numberOfPackets);
			cSketches[i] = new Sketch(1000, 5, numberOfPackets);
			heavyhitterList.add(new HashMap<Long, Long>());
			topKinSubstreams.add(new LinkedList<ArrayList<FlowWithCount>>());

			for (int j = 2; j < (int) (1/threshold); j *= 2)
			{
				LinkedList<ArrayList<FlowWithCount>> listOfL2Bars = topKinSubstreams.get(i);
				listOfL2Bars.addFirst(new ArrayList<FlowWithCount>(k));
				topKinSubstreams.set(i, listOfL2Bars);
			}
		}
	}

	private void performOneUpdate(int i, long key){
		//cSketches[i].updateCountInCountSketch(key);
		cSketches[i].updateCountInSketch(key);

		long minKey = -1;
		long minCount = -1;
		boolean flag = false;
		for (Long k : heavyhitterList.get(i).keySet()){
			if (flag == false || heavyhitterList.get(i).get(k) < minCount){
				minCount = heavyhitterList.get(i).get(k);
				minKey = k;
				flag = true;
			}
		}

		HashMap<Long, Long> curList = heavyhitterList.get(i);
		/* count sketch version
		if (curList.size() == k && cSketches[i].estimateCountinCountSketch(key) > minCount){
			curList.put(key, cSketches[i].estimateCountinCountSketch(key));
			curList.remove(minKey);
		} 
		else if (curList.size() < k)
			curList.put(key, cSketches[i].estimateCountinCountSketch(key));*/


		if (curList.size() == k && cSketches[i].estimateCount(key) > minCount){
			curList.put(key, cSketches[i].estimateCount(key));
			curList.remove(minKey);
		} 
		else if (curList.size() < k)
			curList.put(key, cSketches[i].estimateCount(key));
		heavyhitterList.set(i, curList);

		LinkedList<ArrayList<FlowWithCount>> listOfL2Bars = topKinSubstreams.get(i);
		long estimate = cSketches[i].estimateCount(key);
		
		// update L2
		l2InSubstreams[i] = Math.sqrt(l2InSubstreams[i]*l2InSubstreams[i] + (estimate + 1)*(estimate + 1) - estimate*estimate);

		if (l2InSubstreams[i] > oldL2inSubstream[i]*2){
			oldL2inSubstream[i] = l2InSubstreams[i];
			ArrayList<FlowWithCount> firstElement = new ArrayList<FlowWithCount>();
			listOfL2Bars.addFirst(firstElement);
			if (listOfL2Bars.size() > Math.floor(Math.log(1/threshold)/Math.log(2)))
			 listOfL2Bars.removeLast();
		}
		ArrayList<FlowWithCount> newList;
		for (int j = 2, k = 0; j < (int) (1/threshold); j *= 2, k++)
		{

			if (estimate > l2InSubstreams[i]/j){
				if (listOfL2Bars.get(k) == null)
					newList = new ArrayList<FlowWithCount>();
				else
					newList = listOfL2Bars.get(k);
				newList.add(new FlowWithCount(key, estimate));
				listOfL2Bars.set(k, newList);
			
				ArrayList<FlowWithCount> oldList = null;
				if (j*2  < (int) (1/threshold))
					oldList = listOfL2Bars.get(k + 1);
				if (oldList != null){
					for (FlowWithCount f : oldList)
						if (f.flowid == key){
							oldList.remove(f);
							break;
						}
					listOfL2Bars.set(k + 1, oldList);
				}
				break;
			}
		}


	}

	public void processData(long key){
		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 5171;
		final int hashA[] = {  1783, 883, 307, 199, 2719, 2851, 1453, 421, 149, 311, 8461, 9839, 10597, 9241, 7027, 11329};
		final int hashB[] = {  73, 109, 233, 2927, 3061, 409, 3079, 2341, 179, 1213, 9871, 10159, 7577, 8147, 11113, 9901};

		totalNumberOfPackets++;

		
		performOneUpdate(numberOfSubstreams, key);
		for (int i = 0; i < numberOfSubstreams; i++){
			// sample, update count sketch, keep track of heavy hitters
			for (int j = 0; j < i; j++){
				int hash = (int) ((hashA[j]*key + hashB[j]) % P) % 2;
				if (hash != 1)
					return;
			}
			performOneUpdate(i, key);
		}
	}

	public int getDroppedPacketInfoCount(){
		return droppedPacketInfoCount;
	}

	public HashMap<Long, Long> getBuckets(){
		return flowMemory;
	}

	public HashMap<Long, Long> getHeavyHitters(){
		HashMap<Long, Long> superList = new HashMap<Long, Long>();
		for (int i = 0; i <= numberOfSubstreams; i++){
			for (Long k : heavyhitterList.get(i).keySet())
				superList.put(k, heavyhitterList.get(i).get(k));
		}
		return superList;
	}

	public Sketch[] getSketches(){
		return cSketches;
	}

}