import java.util.*;

/* 	class that facilitates loss creation on a stream of packets
	by choosing flow(s) to be loss and returning all packets but
	those belonging to the flow*/
public class LossInducer{
	private int numberOfLossyFlows;
	private int granularity;

	public LossInducer(int numberOfLossyFlows, int granularity){
		this.numberOfLossyFlows = numberOfLossyFlows;
		this.granularity = granularity;
	}

	// takes in an original packet stream and a flow that we want to deliberately make lossy
	// and returns a packet stream with all the packets but those on the flow to be lost
	// flow recognized by the srcip
	public static HashSet<Packet> createSingleLossyFlow(ArrayList<Packet> packetStream, String flowToBeLost){
		HashSet<Packet> lossyStream = new HashSet<Packet>();
		long ipToBeLost = FlowDataParser.convertAddressToLong(flowToBeLost);
		for (Packet p : packetStream){
			if (p.getSrcIp() != ipToBeLost){
				lossyStream.add(p);
				//System.out.println(p.getSrcIp());
			}
		}

		return lossyStream;
	}

	// takes in an original packet stream and flows that we want to deliberately make lossy
	// and returns a packet stream with all the packets but those in the flows to be lost
	// flow recognized by the srcip
	public static HashSet<Packet> createSingleLossyFlow(ArrayList<Packet> packetStream, ArrayList<String> flowsToBeLost){
		HashSet<Packet> lossyStream = new HashSet<Packet>();

		long[] ipsToBeLost = new long[flowsToBeLost.size()];
		int i = 0;
		for (String f: flowsToBeLost){
			ipsToBeLost[i++] = FlowDataParser.convertAddressToLong(f);
		}
		
		for (Packet p : packetStream){
			long srcip = p.getSrcIp();
			//int i;
			for (i = 0; i < ipsToBeLost.length; i++){
				if (p.getSrcIp() == ipsToBeLost[i])
					break;
			}

			if (i == ipsToBeLost.length){
				lossyStream.add(p);
				//System.out.println(p.getSrcIp());
			}
		}

		return lossyStream;
	}
}