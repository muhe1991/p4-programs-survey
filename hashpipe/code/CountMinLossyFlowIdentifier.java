import java.util.*;

 /* incomplete code and hasn't been used */

/* Data Structure that identifies the big losers
   by maintaining a count-min sketch and a heap that
   is updated for every incoming packet by checking
   if the flow it belongs to has exceeded the threshold*/

public class CountMinLossyFlowIdentifier{
	public TreeMap<Long, Integer> heavyhitters; 
	public final Comparator lossyFlowComparator;

	private class LossyFlow{
		long flowid;
		int losscount;

		LossyFlow(long flowid, int losscount){
			this.flowid = flowid;
			this.losscount = losscount;
		}
	}

	static{
		lossyFlowComparator = new Comparator<LossyFlow>(){
			public int compare(LossyFlow a, LossyFlow b){
				return compareTo(a.losscount, b.losscount);
			}
		};

		heavyhitters = new TreeMap<Long, Integer>();
	}

	

	public static void main(String[] args){
		// constants for this LossyFlowIdentifier
		final int K = 5;			// number of buckets in each hash table
		final int N = 15;			// total number of unique keys
		final int H = 4; 			// number of hash functions

		// pass the filename from which the packet data needs to be parsed
		// assuming that a hashSet takes the same time to add as an array list
		HashSet<Packet> originalPacketStream = parseData(args[1]);

		// read the flow to be lost from the command line and create a new stream with that flow lost
		long flowToBeLost = Integer.parseInt(args[2]);
		HashSet<Packet> finalPacketStream = LossInducer.createSingleLossyFlow(originalPacketStream, flowToBeLost);

		// collect stream data at the start point of the link
		// assumption that you can get this difference by negative mirroring all the packets
		ArrayList<Packet> lostPacketStream = Packet.computeDiff(originalPacketStream, finalPacketStream);
		Sketch lostPacketSketch = new Sketch(K, H, N);
		long lostPackets = 0;
		for (Packet p : lostPacketStream){
			lostPackets++;
			lostPacketSketch.updateCountInMinSketch(p);
					
			// estimate the loss for the flow that this packet belongs to
			long flowid = p.fivetuple();
			long losscount = lostPacketSketch.estimateLossCount(flowid);

			if ((double) losscount/currentNumberOfPackets > threshold){
				heavyhitters.put(flowid, losscount);				
			}

			if ((double) heavyhitters.get(minKey)/currentNumberOfPackets < threshold){
				heavyhitters.remove(minKey);
			}
		}

		for (LossyFlow flow : heavyhitters)
			System.out.println(flow.flowid);
	}
	
}