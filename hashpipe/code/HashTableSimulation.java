import java.util.*;

/* hash table simulation to track the unique flows experiencing loss
	using the standard technique where each flow id is hashed exactly
	once to generate one location where the flow and its loss are
	stored*/

public class HashTableSimulation{
	public static void main(String[] args){
		int numberOfTrials = Integer.parseInt(args[0]);
		int numberOfFlows = Integer.parseInt(args[1]);
		int tableSize = Integer.parseInt(args[2]);
		FlowWithCount[] buckets = new FlowWithCount[tableSize];
		int lostPacketCount = 0;


		// hardcoded values for the hash functions given that the number of flows is 100
		final int P = 1019;
		final int hashA = 421;
		final int hashB = 73;

		// array that counts the number of ith packets lost across the trials
		int flowsLostAtIndex[] = new int[numberOfFlows];
		double observedProbFlowLostAtIndex[] = new double[numberOfFlows];
		double expectedProbFlowLostAtIndex[] = new double[numberOfFlows];

		// initialize all the flow tracking buckets to flows with id 0 and count 0
		buckets = new FlowWithCount[tableSize];
		for (int j = 0; j < tableSize; j++){
			buckets[j] = new FlowWithCount(0, 0);
		}

		// create a set of lost packets which consists of i lost packets of flow i
		List<Integer> packets = new ArrayList<>();
		// add i packets of  flowid i
		for (int i = 1; i <= numberOfFlows; i++)
			for (int j = 0; j < i; j++)
				packets.add(i);

		for (int i = 0; i < numberOfTrials; i++){
			Collections.shuffle(packets);
			//lostPacketCount = 0;
			
			// initialize all the buckets to flows with id 0 and count 0
			for (int j = 0; j < tableSize; j++){
				buckets[j].flowid = 0;
				buckets[j].count = 0;
			}

			for (int j = 0; j < packets.size(); j++){
				//int index = (int) (Math.random()*tableSize);
				int index = ((hashA*packets.get(j) + hashB) % P) % (tableSize);
				if (buckets[index].flowid == packets.get(j)) {
					buckets[index].count++;
				}
				else if (buckets[index].flowid == 0) {
					// new flow
					buckets[index].flowid = packets.get(j);
					buckets[index].count = 1;
				}
				else{ // lost flow
					flowsLostAtIndex[packets.get(j) - 1]++;
					lostPacketCount++;
				}			
			}
			/* print out the status of the hashtable - the buckets and the counts*/
			int nonzero = 0;
			for (int j = 0; j < tableSize; j++){
				if (buckets[j].flowid != 0){
					//System.out.println("index " + i + " has flow " + buckets[i].flowid + " with count " + buckets[i].count);
					nonzero++;
				}			
			}
			System.out.println("non-zero buckets " + nonzero + " lost flows " + lostPacketCount);
			//System.out.println(lostPacketCount);
		}

		/* compare the probabilities of losing the ith packet against the recursive formula*/
		/*for (int i = 0; i < numberOfFlows; i++){
			observedProbFlowLostAtIndex[i] = (double) flowsLostAtIndex[i]/numberOfTrials;
			System.out.println(i + 1 + "flow: " + observedProbFlowLostAtIndex[i]);
		}*/
		System.out.println(lostPacketCount/(double) numberOfTrials);
	}
}