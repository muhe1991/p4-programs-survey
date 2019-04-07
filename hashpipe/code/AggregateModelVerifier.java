import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

/*+----------------------------------------------------------------------
 ||
 ||  Class AggregateModelVerifier 
 ||
 ||         Author:  Vibhaa Sivaraman
 ||
 ||        Purpose:  To run simulations to verify if the theoretical 
 ||			expressions for the recall of the heavy hitters for the aggregate
 || 		model under the dleft baseline procedure correspond to the 
 ||			observed recall
 ||
 ||  Aggregate model: each key comes in with its precise 
 ||  frequency and appears exactly once
 ||
 ||  The baseline procedure looks at the d locations that the incoming 
 ||  flow hashes to and if none of those locations are empty, it places the
 ||  incoming flow in place of the minimum of the d if and only if the 
 ||  incoming flow's value itself is larger than that of the minimum.
 ||
 ||  Inherits From:  None
 ||
 ||  Interfaces:  None
 ||
 |+-----------------------------------------------------------------------
 ||
 ||  Class Methods:  runExperiment that runs the dleft-baseline procedure
 ||  on the aggregate data structure on a specific inputStream of aggregate
 ||  key, value pairs. 
 ||
 ++-----------------------------------------------------------------------*/

public class AggregateModelVerifier{
	private static HashSet<Long> expectedHH; // expected set of heavy hitters
	private static HashMap<Long, Integer> flowSizes; // flows along with their actual sizes

	/*---------------------------------------------------------------------
     |
     |  Purpose:  Identify the earthquake from the list of earthquake
	 |	intensities (quakeList) that has the largest magnitude.
	 |	It is assumed that the given list of quake intensities is
	 |	an array-based list of unordered Richter Scale 
	 |	magnitudes; this function performs a simple sequential
	 |	search through the array to locate the position of the
	 |	largest magnitude (the largest value) in the list.
     |
     |  Pre-condition: quakeList holds 1 or more intensities; the
     |      intensities are in no particular order; numEntries holds
     |      the exact number of entries currently in the list.
     |
     |  Post-condition: quakeList and numEntries are unchanged; the 
     |      list position of the entry with the largest magnitude has 
     |      been identified; the position is within the boundaries
     |      of the array.
     |
     |  Parameters:
	 |	type -- the type of the SummaryStructure (Refer to 
	 |         SummaryStrucureType.java for list). BasicHeuristic in this case
	 |  inputStream - data as Flowid, count pairs representing aggregate data
	 |	k - list of k's to run the experiment for - k in the top k hh
	 |	tableSize -- the total number of entries in the hash table
	 | 	D - number of stages
     *-------------------------------------------------------------------*/
	public static void runExperiment(SummaryStructureType type, ArrayList<FlowWithCount> inputStream, int[] k, int tableSize, int D){
		int numberOfTrials = 1000;
		int cumDroppedPacketInfoCount = 0; // cumulative number of packets for whom information is dropped
		int observedSize[] = new int[k.length]; // number of reported hh
		int expectedSize[] = new int[k.length]; // number of actual hh
		int numberOfFalsePositives[] = new int[k.length];
		int numberOfFalseNegatives[] = new int[k.length];
		long hhPacketsReported[] = new long[k.length]; // number of packets belonging to hh reported or counted
		long hhPacketCount[] = new long[k.length]; // number of packets belonging to hh
		float occupiedSlots[] = new float[k.length];
		float duplicates[] = new float[k.length]; // number of duplicate entries in the table
		double cumDeviation[] = new double[k.length]; // cumulative deviation in reported size across all flows
		int nonHHCompetitors[] = new int[D + 1]; // tracks number of HH competitors each flow competes against on average

		// track the unique heavy hitters
		DLeftHashTable lostFlowHashTable = null;
		HashMap<Long, Long> observedHH = new HashMap<Long, Long>();

		// index at which k for comparing number of heavy hitters is at
		int comp_index = 0;

		for (int t = 0; t < numberOfTrials; t++){
			Collections.shuffle(inputStream);

			/*if (t < 2){
				for (int i = 0; i < 15; i++)
					System.err.println(inputStream.get(i).flowid + "," + inputStream.get(i).count);
				System.err.println("new trial");
			}*/

			lostFlowHashTable = new DLeftHashTable(tableSize, type, inputStream.size(), D, flowSizes);

			// given input, so ideal order of heavy hitters
			FlowWithCount[] inputStreamArray = new FlowWithCount[inputStream.size()];
			inputStreamArray = inputStream.toArray(inputStreamArray);
			Arrays.sort(inputStreamArray);

			// first k in inputStream are expected hh - fix which heavy hitters you look at for cdf of competitors
			expectedHH = new HashSet<Long>();
			for (int i = 0; i < k[comp_index]; i++){
				expectedHH.add(inputStreamArray[i].flowid);
			}

			int count = 0;
			for (FlowWithCount f : inputStream){
				lostFlowHashTable.processAggData(f.flowid, count++, f.count, nonHHCompetitors, expectedHH);				
			}

			// observed flows in sorted order so that we can pick the hh as the top k
			FlowWithCount[] outputFlowBuckets = Arrays.copyOf(lostFlowHashTable.getBuckets(), lostFlowHashTable.getBuckets().length);
			Arrays.sort(outputFlowBuckets);
			
			cumDroppedPacketInfoCount += lostFlowHashTable.getDroppedPacketInfoCount();			

			// find the top k for different k values and compare expected against observed
			for (int k_index = 0; k_index < k.length; k_index++){
				observedHH = new HashMap<Long, Long>();
				for (int i = 0; i < k[k_index]; i++){
					if (observedHH.containsKey(outputFlowBuckets[i].flowid))
						System.out.println("duplicate");
					observedHH.put(outputFlowBuckets[i].flowid, outputFlowBuckets[i].count);
				}

				int hhPacketsLost = 0;
				int flag = 0;
				double deviation = 0;
				double denominator = 0;

				// first k in inputStream are expected hh
				expectedHH = new HashSet<Long>();
				for (int i = 0; i < k[k_index]; i++){
					expectedHH.add(inputStreamArray[i].flowid);
				}
			
				// compute false negative percentage and percentage of actual hh's packets that 
				// are actually reported
				for (long flowid : expectedHH){
					if (!observedHH.containsKey(flowid)){
						numberOfFalseNegatives[k_index]++;
					}
					else
						hhPacketsReported[k_index] += flowSizes.get(flowid);
					hhPacketCount[k_index] += flowSizes.get(flowid);
				}

				expectedSize[k_index] = expectedHH.size();
				observedSize[k_index] = observedHH.size();

				// look at the observed HH and check for false positive and deviation in those reported
				for (long flowid : observedHH.keySet()){
					if (!expectedHH.contains(flowid)){
						numberOfFalsePositives[k_index]++;
					}
					if (flowSizes.get(flowid) == null)
						System.out.println(FlowDataParser.convertLongToAddress(flowid));
					deviation += Math.abs(observedHH.get(flowid) - flowSizes.get(flowid));
					denominator += flowSizes.get(flowid);
				}

				cumDeviation[k_index] += deviation/denominator;
			}
		}

		// print statistics
		for (int k_index = 0; k_index < k.length; k_index++){
			System.out.print(tableSize + "," + k[k_index] + "," + D + ",");
			System.out.print((double) numberOfFalsePositives[k_index]/numberOfTrials/observedSize[k_index] + ",");
			System.out.print((double) numberOfFalseNegatives[k_index]/numberOfTrials/expectedSize[k_index] + ",");
			System.out.print(expectedSize[k_index] + "," + observedSize[k_index] + "," + (double) hhPacketsReported[k_index]/hhPacketCount[k_index]);
			System.out.println("," + cumDeviation[k_index]/numberOfTrials + "," + numberOfFalsePositives[k_index] + "," + numberOfFalseNegatives[k_index]);
		}

		System.err.print(tableSize + "," + k[comp_index] + "," + D + ",");
		for (int j = 0; j <= D; j++)
			System.err.print(nonHHCompetitors[j]/numberOfTrials + ",");
		System.err.println();
	}

	public static void main(String[] args){
		ArrayList<FlowWithCount> inputAggPacketStream = new ArrayList<FlowWithCount>(); // input stream in a convenient format
		flowSizes = new HashMap<Long, Integer>(); // hashmap of all flowids to their actual sizes
		int totalPacketsLost = 0;

		// file that has the srcip addresses matched with size of all flows on different lines in the format "srcip, size\n" 
		File file = new File(args[0]); 

		// prepare inputAggPacketStream accordingly to run experiment - in an arraylist of flowids and associated counts
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
				flowSizes.put(FlowDataParser.convertAddressToLong(fields[0]), Integer.parseInt(fields[1]));
				totalPacketsLost+= Integer.parseInt(fields[1]);
				FlowWithCount f = new FlowWithCount(FlowDataParser.convertAddressToLong(fields[0]), Integer.parseInt(fields[1]));
				inputAggPacketStream.add(f);
			}
			scanner.close();
		}
		catch (FileNotFoundException e)
		{
			System.err.format("Exception occurred trying to read '%s'.", args[0]);
			e.printStackTrace();
			return;
		}
		
		//final int tableSize[] = {30, 75, 150, 300, 500, 900, 1200, 1500, 2000};
		//final int tableSize[] = {/*100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1400, 1600, 1800, 1024, 2048/*, 4096, 8192*/};
		final int k[] = {50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750};
		final int tableSize[] = {2520, 5040, 7560, /*10080*/}; // LCM of the first 12 integers
		//final int tableSize[] = {64};

		if (true)	{
			System.out.println("tableSize" + "," + "k" + "," + "D," + "FalsePositive %" + "," + "False Negative %" + "," + "expected number, reported number, bigLoserReportedFraction, deviation, false positive, false negative");
			for (int tableSize_index = 0; tableSize_index < tableSize.length; tableSize_index++) { 
				for (int D = 2; D <= 15; D++){
					if (D == 11 || D == 13) // not exact divisors, so will leave some space
						continue;
					if (args[1].contains("Basic"))
						runExperiment(SummaryStructureType.BasicHeuristic, inputAggPacketStream, k, tableSize[tableSize_index], D);
					else if (args[1].contains("Single"))
						runExperiment(SummaryStructureType.RollingMinSingleLookup, inputAggPacketStream, k, tableSize[tableSize_index], D);
				}
			}
		}
	}
}

	