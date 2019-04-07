import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

/* high level procedure that uses packet info from a csv file, parses it,
   induces loss on it, and produces a sketch for the lost packet on which
   the big loser identification process is performed 

   initially written for the sketches to all be reversible so that the 
   reversibility procedure would identify the lossy buckets - unused 
   code in the context of the hash table approach*/
public class LossyFlowIdentifierAsymmetricDLeft{
	private static HashSet<Long> expectedHH;
	private static HashMap<Long, Integer> flowSizes;
	private static ArrayList<String> flowsToBeLost;
	/*public static PriorityQueue<LossyFlow> HeapOfLossyFlows; 
	private class BucketMatrixIndex{
		int hashfunctionIndex;
		int bucketIndex;

		public BucketMatrixIndex(int i, int j){
			hashfunctionIndex = i;
			bucketIndex = j;
		}
	}

	public static ArrayList<BucketMatrixIndex> identifyLossyBuckets(FlowHashTable sketch, double threshold){
		ArrayList<BucketMatrixIndex> lossyBuckets = new ArrayList<BucketMatrixIndex>();

		// process the sketch and identify the flows with high loss
		for (int i = 0; i < sketch.getNumberOfHashFunctions(); i++){
			for (int j = 0; j < sketch.getSize(); j++){
				if (sketch.hashMatrix[i][j] > threshold*sketch.totalNumberOfPackets)
					lossyBuckets.add(new BucketMatrixIndex(i, j));
			}
		}
	}

	public static ArrayList<long> identifyFlowsFromBuckets(ArrayList<BucketMatrixIndex> lossyBuckets){
		for (matrixindex : lossyBuckets){
			// break the bucketindex into its words
		}

	}*/

	public static void runLossIdentificationTrials(SummaryStructureType type, Sketch originalPacketSketch, ArrayList<Packet> lostPacketStream, double[] threshold, int tableSize, int D){
		int numberOfTrials = 1000;
		int cumDroppedPacketInfoCount = 0;
		int observedSize[] = new int[threshold.length];
		int expectedSize[] = new int[threshold.length];
		int numberOfFalsePositives[] = new int[threshold.length];
		int numberOfFalseNegatives[] = new int[threshold.length];
		long bigLoserPacketReported[] = new long[threshold.length];
		long bigLoserPacketCount[] = new long[threshold.length];
		float occupiedSlots[] = new float[threshold.length];
		float duplicates[] = new float[threshold.length];

		double cumDeviation[] = new double[threshold.length];
		HashMap<Long, Long> observedHH = new HashMap<Long, Long>();
		for (int t = 0; t < numberOfTrials; t++){

			// track the unique lost flows
			DLeftHashTable lostFlowHashTable = null;
			GroupCounters gcHashTable = null;

			if (type == SummaryStructureType.GroupCounters)
				gcHashTable = new GroupCounters(tableSize, type, lostPacketStream.size(), D);
			else
				lostFlowHashTable = new DLeftHashTable(tableSize, type, lostPacketStream.size(), D);

			int count = 0;
			for (Packet p : lostPacketStream){
				//lostPacketSketch.updateCountInSketch(p);
				//System.out.println(p.getSrcIp());
				if (type == SummaryStructureType.GroupCounters)
					gcHashTable.processData(p.getSrcIp());
				else
					lostFlowHashTable.processData(p.getSrcIp(), count++);
				
			}

			if (type == SummaryStructureType.GroupCounters)
				cumDroppedPacketInfoCount += gcHashTable.getDroppedPacketInfoCount();
			else
				cumDroppedPacketInfoCount += lostFlowHashTable.getDroppedPacketInfoCount();
			

			for (int thr_index = 0; thr_index < threshold.length; thr_index++){
				observedHH = new HashMap<Long, Long>();
				if (type == SummaryStructureType.EvictionWithoutCount){
					Sketch lossEstimateSketch = lostFlowHashTable.getSketch();
					for (Long f : lostFlowHashTable.getFlowIdBuckets()){
						if (f != 0)
							occupiedSlots[thr_index]++;

						if (f != 0 && lossEstimateSketch.estimateCount(f) > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f, lossEstimateSketch.estimateCount(f));
						//System.out.println(f.flowid);
						}
					}
				}
				else if (type == SummaryStructureType.RollingMinSingleLookup || type == SummaryStructureType.AsymmetricDleftSingleLookUp){
					HashMap<Long, Long> currentFlows = new HashMap<Long, Long>();
					for (FlowWithCount f : lostFlowHashTable.getBuckets()){
						if (f.flowid != 0)
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

					for (Long f : currentFlows.keySet()){
						//System.out.println(f.flowid + " " + f.count); 
						if (currentFlows.get(f) > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f, currentFlows.get(f));
						//System.out.println(f.flowid);
						}
					}
				}
				else if (type == SummaryStructureType.GroupCounters){
					HashMap<Long, Long> currentFlows = new HashMap<Long, Long>();
					for (FlowWithCount f : gcHashTable.getBuckets()){
						if (f.flowid != 0)
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

					for (FlowWithCount f : gcHashTable.getBuckets()){
						//System.out.println(f.flowid + " " + f.count); 

						// give it benefit of doubt?
						if (2*f.count > threshold[thr_index]*lostPacketStream.size()){
							observedHH.put(f.flowid, f.count);
						//System.out.println(f.flowid);
						}
					}
				}
				else {
					HashMap<Long, Long> currentFlows = new HashMap<Long, Long>();
					for (FlowWithCount f : lostFlowHashTable.getBuckets()){
						if (f.flowid != 0)
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

					for (FlowWithCount f : lostFlowHashTable.getBuckets()){
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

				expectedHH = new HashSet<Long>();
				for (String f : flowsToBeLost){
					if (flowSizes.get(FlowDataParser.convertAddressToLong(f)) > (int) (threshold[thr_index] * lostPacketStream.size())){
						expectedHH.add(FlowDataParser.convertAddressToLong(f));
					}
				}

				for (long flowid : expectedHH){
					if (!observedHH.containsKey(flowid)){
						numberOfFalseNegatives[thr_index]++;
					}
					else
						bigLoserPacketReported[thr_index] += flowSizes.get(flowid);
					bigLoserPacketCount[thr_index] += flowSizes.get(flowid);
				}

				expectedSize[thr_index] = expectedHH.size();
				observedSize[thr_index] = observedHH.size();

				for (long flowid : observedHH.keySet()){
					//System.out.println("hello");
					//System.out.println(FlowDataParser.convertLongToAddress(flowid));
					if (!expectedHH.contains(flowid)){
						//System.out.println(FlowDataParser.convertLongToAddress(flowid));
						numberOfFalsePositives[thr_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(FlowDataParser.convertLongToAddress(flowid));
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
	}

	public static void runSizeDifferenceMeasurement(SummaryStructureType type, Sketch originalPacketSketch, ArrayList<Packet> lostPacketStream, int tableSize){
		int numberOfTrials = 1000;
		int cumDroppedPacketInfoCount = 0;
		float occupiedSlots = 0;
		float duplicates = 0;

		double cumDeviation = 0;
		//ArrayList<HashMap<Long, Long>> listOfobservedHH = new ArrayList<HashMap<Long, Long>>();
		//ArrayList<HashMap<Long, ArrayList<Double>>> listOfobservedDeviation = new ArrayList<HashMap<Long, ArrayList<Double>>>();
		double deviation;
		int D = 2;
		//for (int D = 3; D <= 15; D+=2){
			HashMap<Long, Long> observedHH = new HashMap<Long, Long>();
			HashMap<Long, ArrayList<Double>> observedDeviation = new HashMap<Long, ArrayList<Double>>();
			HashMap<Long, Long> observedLossyFlowProb = new HashMap<Long, Long>();
			HashMap<Long, Long> currentLossyFlows = new HashMap<Long, Long>();
			ArrayList<Double> observedDeviationList;

			for (int t = 0; t < numberOfTrials; t++){
				currentLossyFlows = new HashMap<Long, Long>();
				// track the unique lost flows
				DLeftHashTable lostFlowHashTable = new DLeftHashTable(tableSize, type, lostPacketStream.size(), D);
				int count = 0;
				for (Packet p : lostPacketStream){
				//lostPacketSketch.updateCountInSketch(p);
				//System.out.println(p.getSrcIp());
					lostFlowHashTable.processData(p.getSrcIp(), count++);
				}

				cumDroppedPacketInfoCount += lostFlowHashTable.getDroppedPacketInfoCount();

				if (type == SummaryStructureType.EvictionWithoutCount){
					Sketch lossEstimateSketch = lostFlowHashTable.getSketch();
					for (Long f : lostFlowHashTable.getFlowIdBuckets()){
						if (f != 0)
							occupiedSlots++;

					//if (f != 0 && lossEstimateSketch.estimateLossCount(f) > threshold*lostPacketStream.size()){
						currentLossyFlows.put(f, lossEstimateSketch.estimateCount(f));
					}
				}
				else {
					for (FlowWithCount f : lostFlowHashTable.getBuckets()){
						if (f.flowid != 0)
							occupiedSlots++;

					if (currentLossyFlows.containsKey(f.flowid)){ // coalesce multiple values
						if (type == SummaryStructureType.RollingMinSingleLookup || type == SummaryStructureType.AsymmetricDleftSingleLookUp)
							currentLossyFlows.put(f.flowid, currentLossyFlows.get(f.flowid) + f.count);
						else
							currentLossyFlows.put(f.flowid, f.count);
						duplicates++;
					}
					else
						currentLossyFlows.put(f.flowid, f.count); // use the last value
					}
				}

				for (long f : currentLossyFlows.keySet()){
					deviation = (flowSizes.get(f) - currentLossyFlows.get(f))/(float)flowSizes.get(f);
					System.out.println(flowSizes);
					System.out.println(currentLossyFlows);
					if (observedHH.containsKey(f)){
						observedHH.put(f, observedHH.get(f) + currentLossyFlows.get(f));
						observedLossyFlowProb.put(f, observedLossyFlowProb.get(f) + 1);
						
						// append current deviation to the arraylist
						observedDeviationList = observedDeviation.get(f);
						observedDeviationList.add(deviation);
						observedDeviation.put(f, observedDeviationList);
					}
					else {
						observedHH.put(f, currentLossyFlows.get(f));
						observedLossyFlowProb.put(f, (long) 1);

						// append current deviation to the arraylist
						observedDeviationList = new ArrayList<Double>();
						observedDeviationList.add(deviation);
						observedDeviation.put(f, observedDeviationList);
					}
				}
			}
			//listOfobservedHH.add(observedHH);
			//listOfobservedDeviation.add(observedDeviation);
		//}

		for (long flowid : flowSizes.keySet()){
			// what do i do about expected lost flows not in the observed lossy flows?
			//if (!expectedHH.contains(flowid)){
				//}
			System.out.print(flowSizes.get(flowid) + ",");
			//for (int D = 3; D <= 15; D+=2){
				if (observedHH.containsKey(flowid)){
					System.out.print(observedHH.get(flowid)/(float) numberOfTrials + "," /*+ observedLossyFlowProb.get(flowid)/(float) numberOfTrials*/);
					double total = 0;
					for (double d : observedDeviation.get(flowid))
						total += d;
					System.out.print(total/observedDeviation.get(flowid).size() + ",");
				}
				else
					System.out.print("0, 1,");
			//}
			System.out.println();
		}
		//System.out.println("Table Occupancy: " + occupiedSlots/tableSize/numberOfTrials);
	}

	public static void runTrialsOnSketch(SummaryStructureType type, ArrayList<Packet> lostPacketStream, double[] threshold, int totalMemory, int D, long thr_totalPackets){
		int numberOfTrials = 1000;
		int observedSize[] = new int[threshold.length];
		int expectedSize[] = new int[threshold.length];
		int numberOfFalsePositives[] = new int[threshold.length];
		int numberOfFalseNegatives[] = new int[threshold.length];
		long hhPacketReported[] = new long[threshold.length];
		long hhPacketCount[] = new long[threshold.length];
		float occupancy[] = new float[threshold.length];
		double cumDeviation[] = new double[threshold.length];

		int observedSizeFromDump[] = new int[threshold.length];
		int numberOfFalsePositivesinDump[] = new int[threshold.length];
		int numberOfFalseNegativesinDump[] = new int[threshold.length];
		long hhPacketReportedinDump[] = new long[threshold.length];
		double cumDeviationinDump[] = new double[threshold.length];
		int cacheSize[] = new int[threshold.length];

		int thr_max = (type == SummaryStructureType.CountMinCacheWithKeys) ? threshold.length : threshold.length - 1;
		
		HashMap<Long, Long> observedHH;
		HashMap<Long, Long> observedHHfromDump;
		for (int t = 0; t < numberOfTrials; t++){
			for (int thr_index = 0; thr_index < thr_max; thr_index++){
				// find the expected HH in the idealistic 100% accuracy case
				expectedHH = new HashSet<Long>();
				observedHHfromDump = new HashMap<Long, Long>();
				for (String f : flowsToBeLost){
					if (flowSizes.get(FlowDataParser.convertAddressToLong(f)) > (int) (threshold[thr_index] * lostPacketStream.size())){
						expectedHH.add(FlowDataParser.convertAddressToLong(f));
					}
				}
				expectedSize[thr_index] = expectedHH.size();

				cacheSize[thr_index] = (int) (1.25*expectedSize[thr_index]);
				//System.out.println("cacheSize" + cacheSize);
				// track the unique lost flows
				CountMinWithCache cmsketch;

				if (type == SummaryStructureType.CountMinCacheWithKeys)
					cmsketch = new CountMinWithCache(totalMemory, type, lostPacketStream.size(), D, cacheSize[thr_index], threshold[thr_index], 0);
				else
					cmsketch = new CountMinWithCache(totalMemory, type, lostPacketStream.size(), D, cacheSize[thr_index], threshold[thr_index + 1], threshold[thr_index]);
				for (Packet p : lostPacketStream){
					//lostPacketSketch.updateCountInSketch(p);
					//System.out.println(p.getSrcIp());
					cmsketch.processData(p.getSrcIp(), thr_totalPackets);
				}

				observedHH = cmsketch.getHeavyHitters();
				observedSize[thr_index] = observedHH.size();
				occupancy[thr_index] += (float) cmsketch.getSketch().getOccupancy();
			
				int bigLoserPacketsLost = 0;
				int flag = 0;
				double deviation = 0;
				double denominator = 0;

				if (type == SummaryStructureType.CountMinCacheWithKeys){
					for (FlowWithCount f : cmsketch.getCache()){
						//System.out.println(f.flowid + " " + f.count); 
						if (/*f.flowid != 0 && */f.count > threshold[thr_index]*lostPacketStream.size()){
								observedHHfromDump.put(f.flowid, f.count);
							//System.out.println(f.flowid);
						}
					}
				}
				observedSizeFromDump[thr_index] = observedHHfromDump.size();

				for (long flowid : expectedHH){
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

				for (long flowid : observedHH.keySet()){
					//System.out.println("hello");
					//System.out.println(FlowDataParser.convertLongToAddress(flowid));
					if (!expectedHH.contains(flowid)){
						//System.out.println(FlowDataParser.convertLongToAddress(flowid));
						numberOfFalsePositives[thr_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(FlowDataParser.convertLongToAddress(flowid));
					//System.out.print(observedHH.get(flowid));
					//System.out.print(" flowid=" + flowid + " " + flowSizes.get(flowid));
					/*if (!expectedHH.contains(flowid) && observedHH.get(flowid) > flowSizes.get(flowid)){
						System.out.println(flowid + " " + observedHH.get(flowid) + " " + flowSizes.get(flowid));
					}*/

					deviation += Math.abs(observedHH.get(flowid) - flowSizes.get(flowid));
					denominator += flowSizes.get(flowid);
				}

				cumDeviation[thr_index] += deviation/denominator;

				deviation = 0;
				denominator = 0;
				for (long flowid : observedHHfromDump.keySet()){
					if (!expectedHH.contains(flowid)){
						numberOfFalsePositivesinDump[thr_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(FlowDataParser.convertLongToAddress(flowid));
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

		
		for (int thr_index = 0; thr_index < thr_max; thr_index++){
			double threshold1 = (type == SummaryStructureType.CountMinCacheWithKeys) ? 0 : threshold[thr_index + 1];
			System.out.print(totalMemory + "," + cacheSize[thr_index] + "," + threshold1 + "," + threshold[thr_index] + "," + D + ",");
			System.out.print((double) numberOfFalsePositives[thr_index]/numberOfTrials/observedSize[thr_index] + ",");
			System.out.print((double) numberOfFalseNegatives[thr_index]/numberOfTrials/expectedSize[thr_index] + ",");
			System.out.print(expectedSize[thr_index] + "," + observedSize[thr_index] + "," + (double) hhPacketReported[thr_index]/hhPacketCount[thr_index]);
			System.out.print("," + cumDeviation[thr_index]/numberOfTrials + "," + occupancy[thr_index]/numberOfTrials + ",");

			if (type == SummaryStructureType.CountMinCacheWithKeys){
				System.out.print((double) numberOfFalsePositivesinDump[thr_index]/numberOfTrials/observedSizeFromDump[thr_index] + ",");
				System.out.print((double) numberOfFalseNegativesinDump[thr_index]/numberOfTrials/expectedSize[thr_index] + ",");
				System.out.print(expectedSize[thr_index] + "," + observedSizeFromDump[thr_index] + "," + (double) hhPacketReportedinDump[thr_index]/hhPacketCount[thr_index]);
				System.out.print("," + cumDeviationinDump[thr_index]/numberOfTrials + ",");
			}
			
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
		ArrayList<Packet> originalPacketStream;
		if(args[0].contains("caida") || args[0].contains("Caida"))
			originalPacketStream = FlowDataParser.parseCAIDAPacketData(args[0]);
		else
			originalPacketStream = FlowDataParser.parsePacketData(args[0]);

		// read the flows to be lost from a file mentioned in the command line and create a new stream with that flow lost
		flowsToBeLost = new ArrayList<String>();
		flowSizes = new HashMap<Long, Integer>();
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
				flowSizes.put(FlowDataParser.convertAddressToLong(fields[0]), Integer.parseInt(fields[1]));
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

		HashSet<Packet> finalPacketStream = LossInducer.createSingleLossyFlow(originalPacketStream, flowsToBeLost);

		// perform the tracking of orginal packets at the entry point so that we can find the perflow size
		Sketch originalPacketSketch = new Sketch(500, 3, originalPacketStream.size());
		for (Packet p : originalPacketStream){
			originalPacketSketch.updateCountInSketch(p);
		}

		// collect stream data at the observation point where the statistics are collected for the link
		ArrayList<Packet> lostPacketStream = Packet.computeDiff(originalPacketStream, finalPacketStream);
		//Sketch lostPacketSketch = new Sketch(K, H, lostPacketStream.size());
		
		//final int tableSize[] = {30, 75, 150, 300, 500, 900, 1200, 1500, 2000};
		final int tableSize[] = {/*100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1400, 1600, 1800, */1024, 2048, 4096, 8192};
		//final double threshold[] = {0.008, 0.006, 0.0035, 0.0025, 0.001, 0.0008, 0.0006, 0.00035, 0.00025, 0.0001};
		final double threshold[] = {0.002, 0.001, 0.0009, 0.00075, 0.0006, 0.00045, 0.0003, 0.00015};
		//final double threshold[] = {0.002, 0.0006, 0.003, 0.00015, 0.000075};
		//final int tableSize[] = {2520, 5040, 7560, 10080};

		if (args[2].equals("runTrial"))	{
			System.out.println("tableSize" + "," + "threshold" + "," + "D," + "FalsePositive %" + "," + "False Negative %" + "," + "expected number, reported number, bigLoserReportedFraction, deviation, table occupancy");
			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) { 
				//for (int thr_index = 0; thr_index < threshold.length; thr_index++){
					for (int D = 6; D <= 6; D++){
						if ((D == 16 && (tableSize_index == 0 || tableSize_index == 2)) || D == 17)
							continue;

						if (args[3].contains("AsymmetricDleft") && D !=6)
							continue;
						// change the expected flows to be lost accordingly
						// compare observed and expected lossy flows and compute the probability of erro

						//System.out.println(expectedHH.size() + " " + totalPacketsLost);

			 			//System.out.println(totalPacketsLost + " " + count);

			 			// run the loss identification trials for the appropriate heuristic
						if (args[3].contains("Basic"))
							runLossIdentificationTrials(SummaryStructureType.BasicHeuristic, originalPacketSketch, lostPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("Multi"))
							runLossIdentificationTrials(SummaryStructureType.RollingMinWihoutCoalescense, originalPacketSketch, lostPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("Single"))
							runLossIdentificationTrials(SummaryStructureType.RollingMinSingleLookup , originalPacketSketch, lostPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("coalesce"))
							runLossIdentificationTrials(SummaryStructureType.RollingMinWithBloomFilter , originalPacketSketch, lostPacketStream, threshold, tableSize[tableSize_index], D);
						else if (args[3].contains("AsymmetricDleft"))
							runLossIdentificationTrials(SummaryStructureType.AsymmetricDleftSingleLookUp , originalPacketSketch, lostPacketStream, threshold, tableSize[tableSize_index], D);
						//runLossIdentificationTrials(SummaryStructureType.DLeft, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.BasicHeuristic, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.MinReplacementHeuristic, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.EvictionWithoutCount, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.EvictionWithCount, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.RollingMinWithBloomFilter, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.RollingMinWihoutCoalescense, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
						//runLossIdentificationTrials(SummaryStructureType.RollingMinSingleLookup, originalPacketSketch, lostPacketStream, threshold[thr_index], tableSize[tableSize_index]);
					}
				//}
			}
		}
		else if (args[2].equals("countMin")){
			System.out.print("totalMemory," + "cacheSize," + "threshold1," + "threshold2," + "D," + "FalsePositive %," + "False Negative %," + "expected number, reported number, hhReportedFraction, deviation, table occupancy,");
			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) {
				for (long thr_totalPackets = 10000; thr_totalPackets <= 50000; thr_totalPackets += 10000){
					for (int D = 2; D <= 4; D++){
						//System.out.println(expectedHH.size() + " " + totalPacketsLost);
				 		//System.out.println(totalPacketsLost + " " + count);

				 		// run the loss identification trials for the appropriate heuristic
				 		if (args[3].contains("Keys"))
				 			System.out.print("FalsePositiveinDump %," + "False Negativ in Dump %," + "expected number, reported number in dump, hhReportedFraction in dump, deviation in dump,");
				 		System.out.println();

						if (args[3].contains("NoKeyNoRepBit"))
							runTrialsOnSketch(SummaryStructureType.CountMinCacheNoKeys, lostPacketStream, threshold, tableSize[tableSize_index]*3, D, thr_totalPackets);
						else if (args[3].contains("NoKeyRepBit"))
							runTrialsOnSketch(SummaryStructureType.CountMinCacheNoKeysReportedBit, lostPacketStream, threshold, tableSize[tableSize_index]*3, D, thr_totalPackets);
						else if (args[3].contains("Keys"))
							runTrialsOnSketch(SummaryStructureType.CountMinCacheWithKeys, lostPacketStream, threshold, tableSize[tableSize_index]*3, D, thr_totalPackets);
					}
				}
			}
		}
		else if (args[2].equals("groupCounters")){
			System.out.println("totalMemory," + "cacheSize," + "threshold1," + "threshold2," + "D," + "FalsePositive %," + "False Negative %," + "expected number, reported number, hhReportedFraction, deviation, table occupancy,");
			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) { 
				runLossIdentificationTrials(SummaryStructureType.GroupCounters, originalPacketSketch, lostPacketStream, threshold, tableSize[tableSize_index]*3, 1);
			}
		}
		else {
			int size = Integer.parseInt(args[4]);
			System.out.print("Actual,");
			for (int D = 2; D <= 1024; D*= 2){
				System.out.print(D + "observed,");
			}
			System.out.println();

			if (args[3].contains("Basic"))
				runSizeDifferenceMeasurement(SummaryStructureType.BasicHeuristic, originalPacketSketch, lostPacketStream, size);
			else if (args[3].contains("Multi"))
				runSizeDifferenceMeasurement(SummaryStructureType.RollingMinWihoutCoalescense, originalPacketSketch, lostPacketStream, size);
			else if (args[3].contains("Single"))
				runSizeDifferenceMeasurement(SummaryStructureType.RollingMinSingleLookup, originalPacketSketch, lostPacketStream, size);
			else if (args[3].contains("coalesce"))
				runSizeDifferenceMeasurement(SummaryStructureType.RollingMinWithBloomFilter, originalPacketSketch, lostPacketStream,  size);
					//runSizeDifferenceMeasurement(SummaryStructureType.MinReplacementHeuristic, originalPacketSketch, lostPacketStream, size, D);
					//runSizeDifferenceMeasurement(SummaryStructureType.EvictionWithoutCount, originalPacketSketch, lostPacketStream, size, D);
					//runSizeDifferenceMeasurement(SummaryStructureType.EvictionWithCount, originalPacketSketch, lostPacketStream, size, D);

		}
	}
}