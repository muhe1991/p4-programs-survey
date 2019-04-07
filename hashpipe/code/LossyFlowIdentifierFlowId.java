import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;
import java.math.BigInteger;

/* high level procedure that uses packet info from a csv file, parses it,
   induces loss on it, and produces a sketch for the lost packet on which
   the big loser identification process is performed 

   initially written for the sketches to all be reversible so that the 
   reversibility procedure would identify the lossy buckets - unused 
   code in the context of the hash table approach*/
public class LossyFlowIdentifierFlowId{
	private static HashSet<String> expectedHH;
	private static HashMap<String, Integer> flowSizes;
	private static ArrayList<String> flowsToBeLost;

	private static double accuracy = 0.99;

	public static void runLossIdentificationTrials(SummaryStructureType type, ArrayList<Packet> lostPacketStream, double[] threshold, int tableSize, int D){
		int numberOfTrials = 1;
		int cumDroppedPacketInfoCount = 0;
		int observedSize[] = new int[threshold.length];
		int expectedSize[] = new int[threshold.length];
		int numberOfFalsePositives[] = new int[threshold.length];
		int numberOfFalseNegatives[] = new int[threshold.length];
		long bigLoserPacketReported[] = new long[threshold.length];
		long bigLoserPacketCount[] = new long[threshold.length];
		float occupiedSlots[] = new float[threshold.length];
		float duplicates[] = new float[threshold.length];

		// track the unique lost flows
		DLeftHashTableFlowId lostFlowHashTable = null;
		GroupCounters gcHashTable = null;

		//hashmap to compute which ranked flows get evcited more
		HashMap<Integer, Integer> rankToFrequency = new HashMap<Integer, Integer>();

		double cumDeviation[] = new double[threshold.length];
		HashMap<String, Long> observedHH = new HashMap<String, Long>();
		for (int t = 0; t < numberOfTrials; t++){
			if (type == SummaryStructureType.GroupCounters)
				gcHashTable = new GroupCounters(tableSize, type, lostPacketStream.size(), D);
			else
				lostFlowHashTable = new DLeftHashTableFlowId(tableSize, type, lostPacketStream.size(), D, flowSizes);

			Collections.shuffle(lostPacketStream); // randomizing the order

			int count = 0;
			for (Packet p : lostPacketStream){
				//lostPacketSketch.updateCountInSketchBigHash(p);
				//System.out.println(p.getSrcIp());
				if (type == SummaryStructureType.GroupCounters)
					gcHashTable.processData(p.getSrcIp());
				else
					lostFlowHashTable.processData(p.getFlowId(), count++, rankToFrequency);
				
			}

			if (type == SummaryStructureType.GroupCounters)
				cumDroppedPacketInfoCount += gcHashTable.getDroppedPacketInfoCount();
			else
				cumDroppedPacketInfoCount += lostFlowHashTable.getDroppedPacketInfoCount();
			

			for (int thr_index = 0; thr_index < threshold.length; thr_index++){
				observedHH = new HashMap<String, Long>();
				if (type == SummaryStructureType.EvictionWithoutCount){
					Sketch lossEstimateSketch = lostFlowHashTable.getSketch();
					for (String f : lostFlowHashTable.getFlowIdBuckets()){
						if (f.equals("") == false)
							occupiedSlots[thr_index]++;

						if (f.equals("") !=  true && lossEstimateSketch.estimateCountBigHash(f) > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f, lossEstimateSketch.estimateCountBigHash(f));
						//System.out.println(f.flowid);
						}
					}
				}
				else if (type == SummaryStructureType.RollingMinSingleLookup){
					HashMap<String, Long> currentFlows = new HashMap<String, Long>();
					for (FlowIdWithCount f : lostFlowHashTable.getBuckets()){
						if (f.flowid.equals("") == false)
							occupiedSlots[thr_index]++;

						//System.out.println(f.flowid + " " + f.count); 
						//if (/*f.flowid != 0 && */f.count > threshold*lostPacketStream.size()){
						if (currentFlows.containsKey(f.flowid)){
							currentFlows.put(f.flowid, currentFlows.get(f.flowid) + f.count);
							duplicates[thr_index]++;
						}
						else
							currentFlows.put(f.flowid, f.count);
						//System.out.println(f.flowid);
					}

					for (String f : currentFlows.keySet()){
						//System.out.println(f.flowid + " " + f.count); 
						if (currentFlows.get(f) > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f, currentFlows.get(f));
						//System.out.println(f.flowid);
						}
					}
				}
				/*else if (type == SummaryStructureType.GroupCounters){
					HashMap<Long, Long> currentFlows = new HashMap<Long, Long>();
					for (FlowWithCount f : gcHashTable.getBuckets()){
						if (f.flowid != 0)
							occupiedSlots[thr_index]++;

						//System.out.println(f.flowid + " " + f.count); 
						//if (/*f.flowid != 0 && *//*f.count > threshold*lostPacketStream.size()){
						if (currentFlows.containsKey(f.flowid)){
							currentFlows.put(f.flowid, currentFlows.get(f.flowid));
							duplicates[thr_index]++;
						}
						else
							currentFlows.put(f.flowid, f.count);
						//System.out.println(f.flowid);
					}
					int tracker = 0;
					long[] totalCounter = gcHashTable.getTotalCounter();
					for (FlowWithCount f : gcHashTable.getBuckets()){
						//System.out.println(f.flowid + " " + f.count); 

						// give it benefit of doubt?
						if (totalCounter[tracker++] > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f.flowid, f.count);
						//System.out.println(f.flowid);
						}
					}
				}*/
				else {
					HashMap<String, Long> currentFlows = new HashMap<String, Long>();
					for (FlowIdWithCount f : lostFlowHashTable.getBuckets()){
						if (f.flowid.equals("") != true)
							occupiedSlots[thr_index]++;

						//System.out.println(f.flowid + " " + f.count); 
						//if (/*f.flowid != 0 && */f.count > threshold*lostPacketStream.size()){
						if (currentFlows.containsKey(f.flowid)){
							currentFlows.put(f.flowid, currentFlows.get(f.flowid));
							duplicates[thr_index]++;
						}
						else
							currentFlows.put(f.flowid, f.count);
						//System.out.println(f.flowid);
					}

					for (FlowIdWithCount f : lostFlowHashTable.getBuckets()){
						//System.out.println(f.flowid + " " + f.count); 
						if (/*f.flowid != 0 && */f.count > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f.flowid, f.count);
						//System.out.println(f.flowid);
						}
					}
				}

			
				int bigLoserPacketsLost = 0;
				int flag = 0;
				double deviation = 0;
				double denominator = 0;

				expectedHH = new HashSet<String>();
				for (String f : flowsToBeLost){
					if (flowSizes.get(f) > (int) (threshold[thr_index] * lostPacketStream.size())){
						expectedHH.add(f);
					}
				}

				for (String flowid : expectedHH){
					if (!observedHH.containsKey(flowid)){
						numberOfFalseNegatives[thr_index]++;
					}
					else
						bigLoserPacketReported[thr_index] += flowSizes.get(flowid);
					bigLoserPacketCount[thr_index] += flowSizes.get(flowid);
				}

				expectedSize[thr_index] = expectedHH.size();
				observedSize[thr_index] = observedHH.size();

				for (String flowid : observedHH.keySet()){
					//System.out.println("hello");
					//System.out.println(FlowDataParser.convertLongToAddress(flowid));
					if (!expectedHH.contains(flowid)){
						//System.out.println(FlowDataParser.convertLongToAddress(flowid));
						numberOfFalsePositives[thr_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(flowid);
					//System.out.print(observedHH.get(flowid));
					//System.out.print(" flowid=" + flowid + " " + flowSizes.get(flowid));
					/*if (!expectedHH.contains(flowid) && observedHH.get(flowid) > flowSizes.get(flowid)){
						System.out.println(flowid + " " + observedHH.get(flowid) + " " + flowSizes.get(flowid));
					}*/
					deviation += Math.abs(observedHH.get(flowid) - flowSizes.get(flowid));
					denominator += flowSizes.get(flowid);
				}

				cumDeviation[thr_index] += deviation/denominator;
			}
		}

		for (int thr_index = 0; thr_index < threshold.length; thr_index++){
			System.out.print(tableSize + "," + threshold[thr_index] + "," + D + ",");
			System.out.print((double) numberOfFalsePositives[thr_index]/numberOfTrials/observedSize[thr_index] + ",");
			System.out.print((double) numberOfFalseNegatives[thr_index]/numberOfTrials/expectedSize[thr_index] + ",");
			System.out.print(expectedSize[thr_index] + "," + observedSize[thr_index] + "," + (double) bigLoserPacketReported[thr_index]/bigLoserPacketCount[thr_index]);
			System.out.println("," + cumDeviation[thr_index]/numberOfTrials + "," + occupiedSlots[thr_index]/tableSize/numberOfTrials + "," + duplicates[thr_index]/tableSize/numberOfTrials);
		}

		//lostFlowHashTable.printBuckets();
	}

	public static void runTrialsPerThreshold(SummaryStructureType type, ArrayList<Packet> lostPacketStream, double[] threshold, int totalMemory, int D, long thr_totalPackets){
		int numberOfTrials = 1;
		int observedSize[] = new int[threshold.length];
		int expectedSize[] = new int[threshold.length];
		int numberOfFalsePositives[] = new int[threshold.length];
		int numberOfFalseNegatives[] = new int[threshold.length];
		long hhPacketReported[] = new long[threshold.length];
		long hhPacketCount[] = new long[threshold.length];
		float occupancy[] = new float[threshold.length];
		double cumDeviation[] = new double[threshold.length];
		double cumUnderEstimation[] = new double[threshold.length];
		float controllerReportCount[] = new float[threshold.length];

		int observedSizeFromDump[] = new int[threshold.length];
		int numberOfFalsePositivesinDump[] = new int[threshold.length];
		int numberOfFalseNegativesinDump[] = new int[threshold.length];
		long hhPacketReportedinDump[] = new long[threshold.length];
		double cumDeviationinDump[] = new double[threshold.length];
		int cacheSize[] = new int[threshold.length];

		for (int thr_index = 0; thr_index < threshold.length; thr_index++){
				// find the expected HH in the idealistic 100% accuracy case
			expectedHH = new HashSet<String>();
			//observedHHfromDump = new HashMap<Long, Long>();
			for (String f : flowsToBeLost){
				if (flowSizes.get(f) > (int) (threshold[thr_index] * lostPacketStream.size())){
					expectedHH.add(f);
				}
			}
			expectedSize[thr_index] = expectedHH.size();
		}

		//System.out.println("cacheSize" + cacheSize);
		// track the unique lost flows

		double samplingProb = totalMemory/(double) lostPacketStream.size(); /*(1 - Math.pow(1 - accuracy, 1/thresholdCount))*/
		SampleAndHoldFlowId flowMemoryFromSampling = null;

		if (type == SummaryStructureType.SampleAndHold){
			flowMemoryFromSampling = new SampleAndHoldFlowId(totalMemory, type, lostPacketStream.size(), samplingProb);
			for (Packet p : lostPacketStream){
				flowMemoryFromSampling.processData(p.getFlowId());
			}
		}


		HashMap<String, Long> observedHH;
		HashMap<String, Long> observedHHfromDump;
		for (int t = 0; t < numberOfTrials; t++){
			
			Collections.shuffle(lostPacketStream);

			for (int thr_index = 0; thr_index < threshold.length; thr_index++){
				// find the expected HH in the idealistic 100% accuracy case
				expectedHH = new HashSet<String>();
				observedHHfromDump = new HashMap<String, Long>();
				observedHH = new HashMap<String, Long>();
				for (String f : flowsToBeLost){
					if (flowSizes.get(f) > (int) (threshold[thr_index] * lostPacketStream.size())){
						expectedHH.add(f);
					}
				}
				expectedSize[thr_index] = expectedHH.size();
				cacheSize[thr_index] = (int) (1.0/threshold[thr_index]) + 20;/* (1.25*expectedSize[thr_index]);*/

				CountMinFlowIdWithCache cmsketch = null;
		    	UnivMon univmon = null;
		    	double thresholdCount = lostPacketStream.size() * threshold[thr_index];
				
				if (type == SummaryStructureType.UnivMon)
					univmon = new UnivMon(totalMemory, type, lostPacketStream.size(), 0, threshold[thr_index]);
				else if (type == SummaryStructureType.CountMinCacheWithKeys)
					cmsketch = new CountMinFlowIdWithCache(totalMemory/2, type, lostPacketStream.size(), D, totalMemory/2, threshold[thr_index], 0);

				if (type != SummaryStructureType.SampleAndHold){
					for (Packet p : lostPacketStream){
						cmsketch.processData(p.getFlowId(), thr_totalPackets);
					}
				}

				// get the heavy hitters from a dump of the cache and track them separately
				if (type == SummaryStructureType.CountMinCacheWithKeys){
					for (FlowIdWithCount f : cmsketch.getCache()){
						//System.out.println(f.flowid + " " + f.count); 
						if (f.count > threshold[thr_index]*lostPacketStream.size()){
							observedHHfromDump.put(f.flowid, f.count);
						}
					}
				}
				observedSizeFromDump[thr_index] = observedHHfromDump.size();

				// get the heavy hitters from the sample and hold flow memory
				if (type == SummaryStructureType.SampleAndHold){
					cacheSize[thr_index] = flowMemoryFromSampling.getBuckets().size();
					for (String f : flowMemoryFromSampling.getBuckets().keySet()){
						if (flowMemoryFromSampling.getBuckets().get(f) > threshold[thr_index]*lostPacketStream.size())
							observedHH.put(f, flowMemoryFromSampling.getBuckets().get(f));
					}
				}
				/*else if (type == SummaryStructureType.UnivMon)
					observedHH = univmon.getHeavyHitters();*/
				else {
					//get the heavy hitters and clean them up
					/*observedHH = cmsketch.getHeavyHitters();
					ArrayList<String> flowsToRemove = new ArrayList<String>();
					for (String flowid : cmsketch.getHeavyHitters().keySet()) {
						if (type == SummaryStructureType.CountMinCacheNoKeys && cmsketch.getHeavyHitters().get(flowid) > threshold[thr_index]*lostPacketStream.size())
							observedHH.put(flowid, cmsketch.getHeavyHitters().get(flowid));
						if (type == SummaryStructureType.CountMinCacheWithKeys && observedHH.get(flowid) <= threshold[thr_index]*lostPacketStream.size()){
							// check if the cache has a mre updated value that would account for this particular flowid being a hh
							// you would technically hash on this flowid and look up that index -- eliminated that part
							if (!observedHHfromDump.containsKey(flowid))
								flowsToRemove.add(flowid);
							else if (observedHHfromDump.get(flowid) <= threshold[thr_index]*lostPacketStream.size())
								flowsToRemove.add(flowid);
						}
					}
					for (String flowid : flowsToRemove)
						observedHH.remove(flowid);*/
					if (type == SummaryStructureType.CountMinCacheWithKeys){
						FlowIdWithCount[] outputFlowBuckets = cmsketch.getCache();
						for (FlowIdWithCount f : outputFlowBuckets){
							if (f.count > threshold[thr_index]*lostPacketStream.size())
								observedHH.put(f.flowid, f.count);
						}
					}
					//System.out.println("after cleaning: " + observedHH.size());
				}

				observedSize[thr_index] = observedHH.size();
				if (type != SummaryStructureType.SampleAndHold && type != SummaryStructureType.UnivMon) {
					occupancy[thr_index] += (float) cmsketch.getSketch().getOccupancy();
					controllerReportCount[thr_index] += (float) cmsketch.getControllerReports();
				}

				/*if (type == SummaryStructureType.UnivMon) {
					float curOccupancy = 0;
					for (Sketch s : univmon.getSketches())
						curOccupancy += (float) s.getOccupancy();
					curOccupancy /= univmon.getSketches().length;
					occupancy[thr_index] += curOccupancy;
				}*/


			
				int bigLoserPacketsLost = 0;
				int flag = 0;
				double deviation = 0;
				double underEstimation = 0;
				double denominator = 0;

				for (String flowid : expectedHH){
					if (!observedHH.containsKey(flowid)){
						numberOfFalseNegatives[thr_index]++;
					}
					else
						hhPacketReported[thr_index] += flowSizes.get(flowid);

					if (!observedHHfromDump.containsKey(flowid)){
						numberOfFalseNegativesinDump[thr_index]++;
					}
					else
						hhPacketReportedinDump[thr_index] += flowSizes.get(flowid);
					
					hhPacketCount[thr_index] += flowSizes.get(flowid);
				}

				for (String flowid : observedHH.keySet()){
					//System.out.println("hello");
					//System.out.println(FlowDataParser.convertLongToAddress(flowid));
					if (!expectedHH.contains(flowid)){
						//System.out.println(FlowDataParser.convertLongToAddress(flowid));
						numberOfFalsePositives[thr_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(flowid);
					//System.out.print(observedHH.get(flowid));
					//System.out.print(" flowid=" + flowid + " " + flowSizes.get(flowid));
					/*if (!expectedHH.contains(flowid) && observedHH.get(flowid) > flowSizes.get(flowid)){
						System.out.println(flowid + " " + observedHH.get(flowid) + " " + flowSizes.get(flowid));
					}*/

					underEstimation += -1 * (observedHH.get(flowid) - flowSizes.get(flowid));
					deviation += Math.abs(observedHH.get(flowid) - flowSizes.get(flowid));
					denominator += flowSizes.get(flowid);
				}

				cumDeviation[thr_index] += deviation/denominator;
				cumUnderEstimation[thr_index] += underEstimation/denominator;

				deviation = 0;
				denominator = 0;
				for (String flowid : observedHHfromDump.keySet()){
					if (!expectedHH.contains(flowid)){
						numberOfFalsePositivesinDump[thr_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(flowid);
					//System.out.print(observedHH.get(flowid));
					//System.out.print(" flowid=" + flowid + " " + flowSizes.get(flowid));
					/*if (!expectedHH.contains(flowid) && observedHH.get(flowid) > flowSizes.get(flowid)){
						System.out.println(flowid + " " + observedHH.get(flowid) + " " + flowSizes.get(flowid));
					}*/

					deviation += Math.abs(observedHHfromDump.get(flowid) - flowSizes.get(flowid));
					denominator += flowSizes.get(flowid);
				}

				if (denominator != 0) 
					cumDeviationinDump[thr_index] += deviation/denominator;				
			}
			//System.out.println("D =" + D);
		}

		
		for (int thr_index = 0; thr_index < threshold.length; thr_index++){
			System.out.print(totalMemory + "," + cacheSize[thr_index] + "," + threshold[thr_index] + "," + D + ",");
			System.out.print((double) numberOfFalsePositives[thr_index]/numberOfTrials/observedSize[thr_index] + ",");
			System.out.print((double) numberOfFalseNegatives[thr_index]/numberOfTrials/expectedSize[thr_index] + ",");
			System.out.print(expectedSize[thr_index] + "," + observedSize[thr_index] + "," + (double) hhPacketReported[thr_index]/hhPacketCount[thr_index]);
			System.out.print("," + cumDeviation[thr_index]/numberOfTrials + "," + occupancy[thr_index]/numberOfTrials + "," + thr_totalPackets + "," + controllerReportCount[thr_index]/numberOfTrials + "," + cumUnderEstimation[thr_index]/numberOfTrials + ",");

			if (type == SummaryStructureType.CountMinCacheWithKeys){
				System.out.print((double) numberOfFalsePositivesinDump[thr_index]/numberOfTrials/observedSizeFromDump[thr_index] + ",");
				System.out.print((double) numberOfFalseNegativesinDump[thr_index]/numberOfTrials/expectedSize[thr_index] + ",");
				System.out.print(expectedSize[thr_index] + "," + observedSizeFromDump[thr_index] + "," + (double) hhPacketReportedinDump[thr_index]/hhPacketCount[thr_index]);
				System.out.print("," + cumDeviationinDump[thr_index]/numberOfTrials + ",");
			}
			
			System.out.println();
		}
	}


	public static void getCMSketchCounters(ArrayList<Packet> lostPacketStream, int totalMemory, int D, long thr_totalPackets){
		CountMinFlowIdWithCache cmcache = new CountMinFlowIdWithCache(totalMemory, SummaryStructureType.CountMinCacheNoKeys, lostPacketStream.size(), D, 10, 0.003, 0);

		for (Packet p : lostPacketStream){
			cmcache.processData(p.getFlowId(), thr_totalPackets);
		}

		Sketch cmsketch = cmcache.getSketch();
		long[][] matrix = cmsketch.getMatrix();

		for (int i = 0; i < cmsketch.getSize(); i++){
			for (int j = 0; j < cmsketch.getNumberOfHashFunctions(); j++)
				System.out.print(matrix[j][i] + ",");
			System.out.println();
		}
	}

	public static void main(String[] args){
		// constants for this LossyFlowIdentifier
		//final int K = 5;			// number of buckets in each hash table
		//final int N = 15;			// total number of unique keys
		//final int H = 4; 			// number of hash functions

		//double threshold = 0.000001;
		// pass the filename from which the packet data needs to be parsed
		long start = System.currentTimeMillis();
		ArrayList<Packet> inputPacketStream;
		//flowAggWithSizes = new ArrayList<FlowWithCount>(); // input stream in a convenient format
		//flowSizes = new HashMap<String, Integer>();
		if(args[0].contains("caida") || args[0].contains("Caida"))
			inputPacketStream = FlowDataParser.parseCAIDAPacketData(args[0]);
		else
			inputPacketStream = FlowDataParser.parsePacketData(args[0]);

		/*
		ArrayList<Packet> originalPacketStream;
		if(args[0].contains("caida") || args[0].contains("Caida"))
			originalPacketStream = FlowDataParser.parseCAIDAPacketData(args[0]);
		else
			originalPacketStream = FlowDataParser.parsePacketData(args[0]);*/

		// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		flowsToBeLost = new ArrayList<String>();
		flowSizes = new HashMap<String, Integer>();
		int totalPacketsLost = 0;
		File file = new File(args[1]);
		try
		{
			Scanner scanner = new Scanner(file);
			String line;
			//int linenumber = 0;
			String[] fields = new String[24];
			while (scanner.hasNextLine())
			{
				line = scanner.nextLine();
				fields = line.split(",");
				flowsToBeLost.add(fields[0]);
				flowSizes.put(fields[0], Integer.parseInt(fields[1]));
				totalPacketsLost+= Integer.parseInt(fields[1]);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[1]);
			e.printStackTrace();
			return;
		}

		/*HashSet<Packet> finalPacketStream = LossInducer.createSingleLossyFlow(originalPacketStream, flowsToBeLost);

		// perform the tracking of orginal packets at the entry point so that we can find the perflow size
		Sketch originalPacketSketch = new Sketch(500, 3, originalPacketStream.size());
		for (Packet p : originalPacketStream){
			originalPacketSketch.updateCountInSketchBigHash(p.getFlowId());
		}

		// collect stream data at the observation point where the statistics are collected for the link
		ArrayList<Packet> lostPacketStream = Packet.computeDiff(originalPacketStream, finalPacketStream);*/
		//Sketch lostPacketSketch = new Sketch(K, H, lostPacketStream.size());
		
		final double threshold[] = {8500, 3800, 2600};
		//final int tableSize[] = {100/*, 150, 200, 250, 300, 350, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200};
		final int tableSize[] = {300, 600, 900, 1200, 1500, 1800, 2100, 2400, 3000, 3600, 4200, 4500};
		//final int tableSize[] = {12500, 25000, 50000, 100000, 200000, 400000, 800000};
		//final double threshold[] = {817/*, 614, 370, 192, 87*/};
		//final int tableSize[] = {3000/*, 60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 1050, 1200, 1350, 1500, 1800, 2100/*, 2400, 2700, 3000, 3300, 3600, 3900, 4200, 4500*/};
		//final int tableSize[] = {12500/*, 25000, 50000, 100000, 200000, 400000, 800000*/};
		//final double threshold[] = {3731/*, 2220, 1393, 826, 443, 258, 194 /*817/*, 614, 370, 192, 87*/}; //n- dstip
		//final double threshold[] = {1450, 926, 625, 479, 400, 348, 245, 198/*817/*, 614, 370, 192, 87*/}; // 5tuple
		//final int tableSize[] = {300, 600, 900, 1200/*, 2520/*, 5040, 7560, /*10080*/};
		//final int tableSize[] = {64};

		for (int i = 0; i < threshold.length; i++)
			threshold[i] /= 10000000;

		if (args[2].equals("runTrial"))	{
			System.out.println("tableSize" + "," + "threshold" + "," + "D," + "FalsePositive %" + "," + "False Negative %" + "," + "expected number, reported number, bigLoserReportedFraction, deviation, table occupancy");
			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) { 
				//for (int thr_index = 0; thr_index < threshold.length; thr_index++){
					for (int D = 6; D <= 6; D++){
						if (D == 11 || D == 13)
							continue;
						// change the expected flows to be lost accordingly
						// compare observed and expected lossy flows and compute the probability of erro

						//System.out.println(expectedHH.size() + " " + totalPacketsLost);

			 			//System.out.println(totalPacketsLost + " " + count);

			 			// run the loss identification trials for the appropriate heuristic
						if (args[3].contains("Basic"))
							runLossIdentificationTrials(SummaryStructureType.BasicHeuristic, inputPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("Multi"))
							runLossIdentificationTrials(SummaryStructureType.RollingMinWihoutCoalescense, inputPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("Single"))
							runLossIdentificationTrials(SummaryStructureType.RollingMinSingleLookup , inputPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("coalesce"))
							runLossIdentificationTrials(SummaryStructureType.RollingMinWithBloomFilter , inputPacketStream, threshold, tableSize[tableSize_index], D);
						//runLossIdentificationTrials(SummaryStructureType.DLeft, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.BasicHeuristic, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.MinReplacementHeuristic, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.EvictionWithoutCount, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.EvictionWithCount, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.RollingMinWithBloomFilter, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.RollingMinWihoutCoalescense, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureTdype.RollingMinSingleLookup, originalPacketSketch, inputPacketStream, threshold[thr_index], tableSize[tableSize_index]);
					}
				//}
			}
		}
		else if (args[2].equals("PerThreshold")){
			System.out.print("totalMemory," + "cacheSize," + "threshold," + "D," + "FalsePositive %," + "False Negative %," + "expected number, reported number, hhReportedFraction, deviation, table occupancy, thr_totalPackets, Controlleer Report Count");
			if (args[3].contains("Keys"))
				System.out.print("FalsePositiveinDump %," + "False Negativ in Dump %," + "expected number, reported number in dump, hhReportedFraction in dump, deviation in dump,");
			System.out.println();

			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) {
				if (args[3].contains("SampleAndHold")) {
					runTrialsPerThreshold(SummaryStructureType.SampleAndHold, inputPacketStream, threshold, tableSize[tableSize_index], 0, 0);
					continue;
				}
				else if (args[3].contains("UnivMon")){
					runTrialsPerThreshold(SummaryStructureType.UnivMon, inputPacketStream, threshold, tableSize[tableSize_index]*10, 0, 0);
					continue;
				}
				
				for (long thr_totalPackets = 0; thr_totalPackets <= 0; thr_totalPackets += 100000){
					for (int D = 5; D <= 5; D++){
						//System.out.println(expectedHH.size() + " " + totalPacketsLost);
				 		//System.out.println(totalPacketsLost + " " + count);

				 		// run the loss identification trials for the appropriate heuristic
				 		if (args[3].contains("NoKeyNoRepBit"))
							runTrialsPerThreshold(SummaryStructureType.CountMinCacheNoKeys, inputPacketStream, threshold, tableSize[tableSize_index]*13/2, D, thr_totalPackets);
						else if (args[3].contains("NoKeyRepBit"))
							runTrialsPerThreshold(SummaryStructureType.CountMinCacheNoKeysReportedBit, inputPacketStream, threshold, tableSize[tableSize_index]*13/2, D, thr_totalPackets);
						else if (args[3].contains("Keys"))
							runTrialsPerThreshold(SummaryStructureType.CountMinCacheWithKeys, inputPacketStream, threshold, tableSize[tableSize_index]*15/2, D, thr_totalPackets);
					}
				}
			}
		}
		else if (args[2].equals("groupCounters")){
			System.out.println("totalMemory," + "threshold," + "D," + "FalsePositive %," + "False Negative %," + "expected number, reported number, hhReportedFraction, deviation, table occupancy, duplicates,");
			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) { 
				runLossIdentificationTrials(SummaryStructureType.GroupCounters, inputPacketStream, threshold, tableSize[tableSize_index]*3, 1);
			}
		}
		else if (args[2].equals("CMDist")){
			int D = Integer.parseInt(args[3]);
			int totalMemory = Integer.parseInt(args[4]);
			long thr_totalPackets = Long.parseLong(args[5]);

			for (int i = 0; i < D; i++)
				System.out.print(i + ",");
			System.out.println();

			getCMSketchCounters(inputPacketStream, totalMemory, D, thr_totalPackets);

		}
		/*else {
			double thr = 0.0;
			int size = 0;
			if (args[3].contains("Key"))
				thr = Double.parseDouble(args[4]);
			else
				size = Integer.parseInt(args[4]);

			System.out.println("Actual, observed, deviation");

			if (args[3].contains("Basic"))
				runSizeDifferenceMeasurement(SummaryStructureType.BasicHeuristic, originalPacketSketch, inputPacketStream, size);
			else if (args[3].contains("Multi"))
				runSizeDifferenceMeasurement(SummaryStructureType.RollingMinWihoutCoalescense, originalPacketSketch, inputPacketStream, size);
			else if (args[3].contains("Single"))
				runSizeDifferenceMeasurement(SummaryStructureType.RollingMinSingleLookup, originalPacketSketch, inputPacketStream, size);
			else if (args[3].contains("coalesce"))
				runSizeDifferenceMeasurement(SummaryStructureType.RollingMinWithBloomFilter, originalPacketSketch, inputPacketStream,  size);
			else if (args[3].contains("NoKeyNoRepBit"))
				runSizeDifferenceMeasurementOnSketch(SummaryStructureType.CountMinCacheNoKeys, inputPacketStream, thr, size*10, 300000);
			else if (args[3].contains("Keys"))
				runSizeDifferenceMeasurementOnSketch(SummaryStructureType.CountMinCacheWithKeys, inputPacketStream, thr, size*10, 300000);
		}*/
		System.out.println((System.currentTimeMillis() - start)/1000);
	}
}