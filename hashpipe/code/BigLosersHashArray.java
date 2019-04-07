import java.util.*;

public class BigLosersHashArray{
	public static Long[] flowsSeen; 
	public static final int numberOfFlowsStored;
	public static final double threshold;
	public static final long hashSeedA;
	public static final long hashSeedB;

	static{
		numberOfFlowsStored = 5;
		threshold = 0.5;
		flowsSeen = new Long[numberOfFlowsStored];
		hashSeedA = 59032440799460394L % (long) numberOfFlowsStored;
		hashSeedB = 832108633134565846L % (long) numberOfFlowsStored;
	}

	

	public static void main(String[] args){
		// constants for this LossyFlowIdentifier
		final int K = 5;			// number of buckets in each hash table
		final int N = 15;			// total number of unique keys
		final int H = 4; 			// number of hash functions
		ArrayList<Long> bigLosers = new ArrayList<Long>();

		// pass the filename from which the packet data needs to be parsed
		// assuming that a hashSet takes the same time to add as an array list
		HashSet<Packet> originalPacketStream = FlowDataParser.parsePacketData(args[0]);

		// read the flow to be lost from the command line and create a new stream with that flow lost
		String flowToBeLost = args[1];
		HashSet<Packet> finalPacketStream = LossInducer.createSingleLossyFlow(originalPacketStream, flowToBeLost);

		// collect stream data at the start point of the link
		// assumption that you can get this difference by negative mirroring all the packets
		ArrayList<Packet> lostPacketStream = Packet.computeDiff(originalPacketStream, finalPacketStream);

		// sketch stored in hardware
		Sketch lostPacketSketch = new Sketch(K, H, N); 

		// total number of lost packets counted every time we see a lost packet mirrored
		// data plane operation - formation of the sketch and the array of flows seen so far
		long totalLostPackets = 0;
		for (Packet p : lostPacketStream){
			totalLostPackets++;
			lostPacketSketch.updateCountInMinSketch(p);
					
			// add this flow to the flows seen so far
			long flowid = p.getSrcIp();
			System.out.println(((hashSeedA*(flowid % numberOfFlowsStored))%numberOfFlowsStored + (hashSeedB % (long) numberOfFlowsStored)) % numberOfFlowsStored);
			int index = (int) (((hashSeedA*(flowid % numberOfFlowsStored))%numberOfFlowsStored + (hashSeedB % (long) numberOfFlowsStored)) % numberOfFlowsStored);
			flowsSeen[index] = flowid;
		}

		// control plane operation 
		// go through all the flowids seen and print all the flowids that had losscount more than the threshold
		for (int i = 0; i < numberOfFlowsStored; i++){
			Long flowid = flowsSeen[i];
			long lossCountForFlow = lostPacketSketch.estimateLossCount(flowid);

			if ((double) lossCountForFlow / totalLostPackets > threshold)
				bigLosers.add(flowid);
		}

		for (long flow: bigLosers)
			System.out.println(flow);
	}
	
}